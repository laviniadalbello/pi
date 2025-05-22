package com.example.planify

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mlkit.nl.smartreply.SmartReply
import com.google.mlkit.nl.smartreply.SmartReplySuggestion
import com.google.mlkit.nl.smartreply.TextMessage
import java.util.ArrayList
import java.util.HashMap

class MainActivity: FlutterActivity() {
    private val CHANNEL = "google_mlkit_smart_reply" // O MESMO NOME DO CANAL DO FLUTTER
    private lateinit var channel: MethodChannel
    private lateinit var smartReply: SmartReply // Instância do SmartReply nativo

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        smartReply = SmartReply.getClient() // Obtenha a instância do SmartReply

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "nlp#startSmartReply" -> {
                    val conversationData = call.argument<ArrayList<HashMap<String, Any>>>("conversation")
                    val conversation = parseConversation(conversationData)

                    smartReply.suggestReplies(conversation)
                        .addOnSuccessListener { smartReplySuggestions ->
                            val suggestionsList = smartReplySuggestions.suggestions.map { it.text }
                            val status = when (smartReplySuggestions.status) {
                                SmartReplySuggestion.STATUS_SUCCESS -> 0 // Corresponde a SmartReplySuggestionResultStatus.success.index
                                SmartReplySuggestion.STATUS_NOT_SUPPORTED_LANGUAGE -> 1 // Corresponde a SmartReplySuggestionResultStatus.notSupportedLanguage.index
                                SmartReplySuggestion.STATUS_NO_REPLY -> 2 // Corresponde a SmartReplySuggestionResultStatus.noReply.index
                                else -> 3 // Erro genérico
                            }
                            result.success(mapOf("status" to status, "suggestions" to suggestionsList))
                        }
                        .addOnFailureListener { e ->
                            result.error("SMART_REPLY_ERROR", e.localizedMessage, null)
                        }
                }
                "nlp#closeSmartReply" -> {
                    smartReply.close() // Fecha os recursos do SmartReply
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun parseConversation(conversationData: ArrayList<HashMap<String, Any>>?): List<TextMessage> {
        val messages = mutableListOf<TextMessage>()
        conversationData?.forEach { msgMap ->
            val text = msgMap["message"] as String
            val timestamp = (msgMap["timestamp"] as? Number)?.toLong() ?: System.currentTimeMillis()
            val userId = msgMap["userId"] as String

            if (userId == "user") { // Seu 'sender' == 'user'
                messages.add(TextMessage.createForLocalUser(text, timestamp))
            } else { // Seu 'sender' == 'bot'
                messages.add(TextMessage.createForRemoteUser(text, timestamp, userId))
            }
        }
        return messages
    }

    override fun onDestroy() {
        super.onDestroy()
        smartReply.close() // Garante que o SmartReply seja fechado ao destruir a atividade
    }
}
