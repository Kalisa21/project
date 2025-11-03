import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_overlay.dart';
import '../services/supabase_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  bool _overlayOpen = false;
  bool _isLoading = false;
  String? _currentSessionId;
  String _selectedLanguage = 'en'; // Default language

  // Base URL for FastAPI
  // For Android emulator: run with --dart-define=API_BASE=http://10.0.2.2:8000
  // For iOS simulator/macOS/web: http://127.0.0.1:8000
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://0.0.0.0:8000',
  );

  // Start with no initial message
  final List<Map<String, String>> _msgs = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  /// Load chat history from Supabase
  Future<void> _loadChatHistory() async {
    if (!SupabaseService.isAuthenticated) return;

    try {
      final userId = SupabaseService.currentUser!.id;
      
      // Load recent messages (limit to last 50)
      final response = await SupabaseService.client
          .from('chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true)
          .limit(50);

      if (mounted && response != null && response is List && response.isNotEmpty) {
        setState(() {
          for (final msg in response) {
            if (msg != null && 
                msg is Map<String, dynamic> && 
                msg['id'] != null && 
                msg['content'] != null &&
                msg['role'] != null) {
              final role = msg['role'].toString();
              final content = msg['content'].toString();
              if (content.isNotEmpty) {
                _msgs.add({
                  'id': msg['id'].toString(),
                  'from': role == 'assistant' ? 'bot' : 'user',
                  'text': content,
                });
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      // Continue silently - app works without history
    }
  }

  void _toggleOverlay() => setState(() => _overlayOpen = !_overlayOpen);

  /// Save message to Supabase chat_messages table
  Future<String?> _saveMessageToSupabase({
    required String role, // 'user' or 'assistant'
    required String content,
    String? sessionId,
    Map<String, dynamic>? metadata,
    List<String>? articleReferences,
  }) async {
    if (!SupabaseService.isAuthenticated) return null;

    try {
      final userId = SupabaseService.currentUser!.id;
      
      // Ensure a profile row exists to satisfy the foreign key
      try {
        final existing = await SupabaseService.client
            .from('profiles')
            .select('user_id')
            .eq('user_id', userId)
            .maybeSingle();
        if (existing == null) {
          // Minimal profile
          final email = SupabaseService.currentUser!.email ?? 'user@example.com';
          final fallbackName = email.split('@').first;
          await SupabaseService.client.from('profiles').insert({
            'user_id': userId,
            'name': fallbackName,
            'about': 'User',
            'role': 'user',
          });
        }
      } catch (_) {
        // Ignore; trigger might have created it already
      }

      // Build message data, only including non-null values
      final messageData = <String, dynamic>{
        'user_id': userId,
        'role': role,
        'content': content,
      };
      
      // Only add optional fields if they are not null
      if (sessionId != null && sessionId.isNotEmpty) {
        messageData['session_id'] = sessionId;
      }
      if (metadata != null && metadata.isNotEmpty) {
        messageData['metadata'] = metadata;
      }
      if (articleReferences != null && articleReferences.isNotEmpty) {
        messageData['article_references'] = articleReferences;
      }

      Future<String?> _doInsert() async {
        final response = await SupabaseService.client
            .from('chat_messages')
            .insert(messageData)
            .select()
            .single();
        if (response != null && response is Map<String, dynamic> && response['id'] != null) {
          return response['id'].toString();
        }
        return null;
      }

      try {
        final id = await _doInsert();
        return id;
      } catch (pe) {
        // Retry once if foreign key fails (profile not yet committed)
        final msg = pe.toString().toLowerCase();
        if (msg.contains('23503') || (msg.contains('foreign key') && msg.contains('user_id'))) {
          await Future.delayed(const Duration(milliseconds: 200));
          try {
            final id = await _doInsert();
            return id;
          } catch (_) {}
        }
        debugPrint('DB error saving chat: $pe');
        return null;
      }
    } catch (e) {
      // Outer guard – any unexpected error
      debugPrint('Unexpected error in _saveMessageToSupabase: $e');
      return null;
    }
  }

  Future<void> _send(String text) async {
    if (!SupabaseService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to use the chatbot')),
      );
      return;
    }

    // Add user message to UI
    setState(() {
      _msgs.add({
        'id': DateTime.now().toIso8601String(),
        'from': 'user',
        'text': text,
      });
      _isLoading = true;
    });

    // Save user message to Supabase
    await _saveMessageToSupabase(
      role: 'user',
      content: text,
      sessionId: _currentSessionId,
    );

    try {
      // Call FastAPI endpoint
      final uri = Uri.parse('$apiBase/search');
      final response = await http.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': text,
          'top_k': 1,
          'language_filter': _selectedLanguage,
          'min_score': 0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        final totalResults = data['total_results'] ?? 0;
        final processingTime = data['processing_time_ms'] ?? 0.0;

        if (results.isNotEmpty) {
          // First pass: collect all article IDs
          final articleIds = <String>[];
          for (final result in results) {
            final articleId = result['id']?.toString();
            if (articleId != null) {
              articleIds.add(articleId);
            }
          }

          // Second pass: display and save each result
          for (final result in results) {
            // Extract fields from FastAPI response
            final articleId = result['id']?.toString();
            final articleLabel = result['article_label'] ?? 'Unknown Article';
            final articleText =
                result['article_text'] ?? 'No content available';
            final language = result['language'] ?? 'unknown';
            final score = result['similarity_score'] ?? 0.0;

            // Build formatted response
            final formattedResult =
                '''📋 $articleLabel (${language.toUpperCase()})
🎯 Relevance: ${(score * 100).toStringAsFixed(1)}%

$articleText''';

            // Add to UI
            setState(() {
              _msgs.add({
                'id': DateTime.now().toIso8601String(),
                'from': 'bot',
                'text': formattedResult.trim(),
              });
            });

            // Save each assistant message to Supabase
            await _saveMessageToSupabase(
              role: 'assistant',
              content: formattedResult.trim(),
              sessionId: _currentSessionId,
              metadata: {
                if (articleId != null) 'article_id': articleId,
                'article_label': articleLabel,
                'language': language,
                'similarity_score': score,
                'processing_time_ms': processingTime,
                'total_results': totalResults,
              },
              articleReferences: articleIds.isNotEmpty ? articleIds : null,
            );
          }
        } else {
          // No results found
          final noResultsMsg =
              'No relevant legal articles found for your query. Please try rephrasing your question.';

          setState(() {
            _msgs.add({
              'id': DateTime.now().toIso8601String(),
              'from': 'bot',
              'text': noResultsMsg,
            });
          });

          // Save to Supabase
          await _saveMessageToSupabase(
            role: 'assistant',
            content: noResultsMsg,
            sessionId: _currentSessionId,
            metadata: {
              'total_results': 0,
              'processing_time_ms': processingTime,
              'has_results': false,
            },
          );
        }
      } else {
        // Error response
        final errorMsg =
            '⚠️ ${response.statusCode}: ${response.reasonPhrase}\n${response.body}';

        setState(() {
          _msgs.add({
            'id': DateTime.now().toIso8601String(),
            'from': 'bot',
            'text': errorMsg,
          });
        });

        // Save error to Supabase
        await _saveMessageToSupabase(
          role: 'assistant',
          content: errorMsg,
          sessionId: _currentSessionId,
          metadata: {
            'error': true,
            'status_code': response.statusCode,
          },
        );
      }
    } catch (e) {
      // Connection error
      final errorMsg = '❌ Connection error: $e';

      setState(() {
        _msgs.add({
          'id': DateTime.now().toIso8601String(),
          'from': 'bot',
          'text': errorMsg,
        });
      });

      // Save error to Supabase
      await _saveMessageToSupabase(
        role: 'assistant',
        content: errorMsg,
        sessionId: _currentSessionId,
        metadata: {
          'error': true,
          'error_message': e.toString(),
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 🔹 Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'This version of LegalEase can help you with Rwandan law only.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: _toggleOverlay,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 🔹 Messages list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _msgs.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _msgs.length && _isLoading) {
                        // Show loading bubble
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Typing...",
                              style: TextStyle(
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }

                      final m = _msgs[i];
                      final isBot = m['from'] == 'bot';
                      return Align(
                        alignment: isBot
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isBot ? Colors.white : AppTheme.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m['text']!,
                            style: TextStyle(
                              color: isBot ? Colors.black : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 🔹 Input Field
                ChatInput(onSend: _send),
              ],
            ),

            // 🔹 Overlay for new chat / history / language
            ChatOverlay(
              open: _overlayOpen,
              onClose: _toggleOverlay,
              selectedLanguage: _selectedLanguage,
              onLanguageSelected: (lang) {
                setState(() {
                  _selectedLanguage = lang;
                });
              },
              onNewChat: () {
                setState(() {
                  _msgs.clear();
                  _currentSessionId = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
