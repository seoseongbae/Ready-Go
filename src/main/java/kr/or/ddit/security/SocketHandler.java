package kr.or.ddit.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class SocketHandler extends TextWebSocketHandler {
	private static final Logger logger = LoggerFactory.getLogger(WebSocketHandler.class);
	private Map<String, WebSocketSession> userSessionsMap = new ConcurrentHashMap<>();


    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        // 사용자 정보 가져오기 (세션에서 username을 추출)
        String username = (String) session.getAttributes().get("username");
        userSessionsMap.put(username, session);
        System.out.println("WebSocket connection established for user: " + username);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        String username = (String) session.getAttributes().get("username");
        userSessionsMap.remove(username);
        System.out.println("WebSocket connection closed for user: " + username);
    }

    public Map<String, WebSocketSession> getUserSessionsMap() {
        logger.info("현재 등록된 WebSocket 세션 목록: " + userSessionsMap.keySet());
        return userSessionsMap;
    }

    
    @Bean
    public SocketHandler socketHandler() {
        return new SocketHandler();  // SocketHandler를 Bean으로 등록
    }
    
 // 특정 사용자에게 메시지 전송하는 메서드
    public void sendMessageToUser(String boardWriter, String message) {
        WebSocketSession boardWriterSession = userSessionsMap.get(boardWriter);
        logger.info("현재 요청된 사용자: " + boardWriter); // 요청된 사용자 로그
        logger.info("현재 등록된 세션 목록: " + userSessionsMap.keySet()); // 세션 목록 로그

        if (boardWriterSession != null && boardWriterSession.isOpen()) {
            try {
                boardWriterSession.sendMessage(new TextMessage(message));
                logger.info("메시지를 성공적으로 전송했습니다. 사용자: " + boardWriter + " 메시지: " + message);
            } catch (IOException e) {
                logger.error("메시지 전송 중 오류 발생: ", e);
            }
        } else {
            logger.warn("WebSocket 세션을 찾을 수 없음, 사용자: " + boardWriter);
        }
    }
    
    //채팅
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        String senderUsername = (String) session.getAttributes().get("username");

        // 클라이언트로부터 받은 메시지를 로깅
        logger.info("받은 메시지: " + payload + " / 발신자: " + senderUsername);

        // 모든 연결된 클라이언트에게 메시지 전송 (채팅방 전체 전달)
        for (WebSocketSession webSocketSession : userSessionsMap.values()) {
            if (webSocketSession.isOpen()) {
                webSocketSession.sendMessage(new TextMessage(senderUsername + ": " + payload));
            }
        }
    }


}

