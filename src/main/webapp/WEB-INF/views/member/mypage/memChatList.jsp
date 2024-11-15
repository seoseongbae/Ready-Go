<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec"%>   
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>   
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
<link rel="stylesheet" href="<%=request.getContextPath() %>/resources/css/member/myChatList.css" />
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script> 
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<script type="text/javascript" src="/resources/js/sweetalert2.js"></script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/alert.css" />
<sec:authentication property="principal" var="prc"/>
<script type="text/javascript">
var username = "${pageContext.request.userPrincipal != null ? pageContext.request.userPrincipal.name : 'anonymousUser'}";
</script>
<br>
<div class="container" style="position: relative; bottom: 35px;">
    <p id="h3">채팅 목록</p>
    <br><br>
    <div id="flexDiv">
    <br>
    </div>
    <div class="card-body table-responsive p-0">
        <table class="table table-hover text-nowrap" style="width: 1230px;">
            <thead>
                <tr>
                    <th style="width: 10%;">번호</th>
                    <th style="width: 15%;">대화상대</th>
                    <th style="width: 50%;">마지막채팅</th>
                    <th style="width: 25%;">생성일자</th>
                    <th></th>
                    <th></th>
                </tr>
            </thead>
			<tbody>
			    <c:forEach var="chatRoom" items="${chatRoomList}" varStatus="stat">
			        <tr>
			            <td>${stat.count}</td>  
			            <td>${chatRoom.receiveUser eq prc.username ? chatRoom.senderUser : chatRoom.receiveUser}</td>
			            <td>
			                <c:choose>
			                    <c:when test="${fn:length(chatRoom.lastMessage) > 30}">
			                        ${fn:substring(chatRoom.lastMessage, 0, 30)}...
			                    </c:when>
			                    <c:otherwise>
			                        ${chatRoom.lastMessage}
			                    </c:otherwise>
			                </c:choose>
			            
			                <c:if test="${chatRoom.lastMessageDate != null}">
			                    (<fmt:formatDate value="${chatRoom.lastMessageDate}" pattern="MM.dd HH:mm"/>)
			                </c:if>
			            
			                <c:choose>
			                    <c:when test="${chatRoom.unreadCount > 0 && chatRoom.lastMessageSenderUser != prc.username}">
			                        <!-- 받는 사람이 '안 읽음' 뱃지를 보게 하기 -->
			                        <div class="unread-badge">${chatRoom.unreadCount}</div>
			                    </c:when>
			                    <c:otherwise>
			                        <!-- 송신자에게는 뱃지를 표시하지 않음 -->
			                    </c:otherwise>
			                </c:choose>
			            </td>
			            <td>
			                <fmt:formatDate value="${chatRoom.roomCreateDate}" pattern="yy.MM.dd HH:mm"/>
			            </td>
			            <td>
			                <input type="hidden" class="roomNo" value="${chatRoom.roomNo}">
			                <input type="hidden" class="senderUser" value="${chatRoom.senderUser}">
			                <input type="hidden" class="receiveUser" value="${chatRoom.receiveUser}">
			                <button type="button" class="btn btn-danger chatDel">삭제</button>
			            </td>
			            <td>
							<button type="button" class="btn btn-primary OpenBtn" 
							        onclick="openChatRoom('${chatRoom.roomNo}', '${chatRoom.senderUser}', '${chatRoom.receiveUser}')">
							    입장
							</button>
			            </td>
			        </tr>
			    </c:forEach>
			</tbody>

        </table>
    </div>
</div>
<!-- 모달 구조 수정 -->
<div class="modal fade" id="chatRoomModal" tabindex="-1" role="dialog" aria-labelledby="chatRoomModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="chatRoomModalLabel">채팅방</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close" onclick="disconnectWs();">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <!-- 채팅 내용을 표시할 영역 -->
		<div id="chatContent">
		    <p>채팅 기록이 없습니다. 메시지를 입력하세요!</p>
		</div>
		<div class="form-group">
		    <textarea type="text" id="chatMessage" class="form-control" placeholder="메시지를 입력하세요"></textarea>
		</div>
		    <button type="button" class="btn btn-primary" id="send-btn">전송</button>
      </div>
<!--       <div class="modal-footer" style="display: flex; justify-content: space-between;"> -->
<!--         <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="disconnectWs();">닫기</button> -->
        
<!--       </div> -->
    </div>
  </div>
</div>

<script type="text/javascript">
var Toast = Swal.mixin({
    toast: true,
    position: 'center',
    showConfirmButton: false,
    timer: 1500,
    didOpen: (toast) => {
        toast.addEventListener('mouseenter', Swal.stopTimer);
        toast.addEventListener('mouseleave', Swal.resumeTimer);
    }
});
$(document).ready(function() {
	var mbrId = username; 
    // 모달이 닫힐 때 테이블만 새로고침
    $('#chatRoomModal').on('hidden.bs.modal', function () {
        refreshChatList();  
    });

    // 채팅 목록을 새로고침하는 함수
    function refreshChatList() {
        console.log("refreshChatList 호출됨");
        $.ajax({
            url: '/chat/getChatList',
            type: 'GET',
            beforeSend: function(xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function(response) {
                console.log("서버 응답 받음", response);
                var chatListHtml = '';
                response.forEach(function(chatRoom, index) {
                    chatListHtml += '<tr>';
                    chatListHtml += '<td>' + (index + 1) + '</td>';
                    chatListHtml += '<td>' + (chatRoom.receiveUser === username ? chatRoom.senderUser : chatRoom.receiveUser) + '</td>';
                    
                    chatListHtml += '<td>';
                    if (chatRoom.lastMessage.length > 30) {
                        chatListHtml += chatRoom.lastMessage.substring(0, 30) + '...';
                    } else {
                        chatListHtml += chatRoom.lastMessage;
                    }

                    if (chatRoom.lastMessageDate !== null) {
                        var lastMsgDate = new Date(chatRoom.lastMessageDate);
                        var formattedDate = (lastMsgDate.getMonth() + 1) + '.' + lastMsgDate.getDate() + ' ' + lastMsgDate.getHours() + ':' + ('0' + lastMsgDate.getMinutes()).slice(-2);
                        chatListHtml += ' (' + formattedDate + ')';
                    }

                    if (chatRoom.unreadCount > 0 && chatRoom.lastMessageSenderUser !== username) {
                        chatListHtml += '<div class="unread-badge">' + chatRoom.unreadCount + '</div>';
                    }
                    chatListHtml += '</td>';

                    var roomCreateDate = new Date(chatRoom.roomCreateDate);
                    var formattedCreateDate = (roomCreateDate.getFullYear() % 100) + '.' + (roomCreateDate.getMonth() + 1) + '.' + roomCreateDate.getDate() + ' ' + roomCreateDate.getHours() + ':' + ('0' + roomCreateDate.getMinutes()).slice(-2);
                    chatListHtml += '<td>' + formattedCreateDate + '</td>';

                    chatListHtml += '<td><input type="hidden" class="roomNo" value="' + chatRoom.roomNo + '">';
                    chatListHtml += '<input type="hidden" class="senderUser" value="' + chatRoom.senderUser + '">';
                    chatListHtml += '<input type="hidden" class="receiveUser" value="' + chatRoom.receiveUser + '">';
                    chatListHtml += '<button type="button" class="btn btn-danger chatDel">삭제</button></td>';

                    chatListHtml += '<td><button type="button" class="btn btn-primary OpenBtn" onclick="openChatRoom(\'' + chatRoom.roomNo + '\', \'' + (chatRoom.receiveUser === username ? chatRoom.senderUser : chatRoom.receiveUser) + '\')">입장</button></td>';
                    chatListHtml += '</tr>';
                });

                $('table tbody').html(chatListHtml);
                setDeleteButtonHandlers();  // 삭제 버튼 핸들러 다시 설정
            },
            error: function() {
                alert('채팅 목록을 불러오는 중 오류가 발생했습니다.');
            }
        });
    }
});

var socket = null;
var roomNo = null;  // 채팅방 번호
var checkReadStatusInterval = null;  // 읽음 상태 체크 타이머

// 모달이 닫힐 때 WebSocket 연결 해제
function disconnectWs() {
    if (socket !== null) {
        socket.close();  // WebSocket 연결 해제
        socket = null;
        console.log('WebSocket 연결이 해제되었습니다.');
    }
    // 읽음 상태 체크 중지
    if (checkReadStatusInterval !== null) {
        clearInterval(checkReadStatusInterval);
        checkReadStatusInterval = null;
    }
}

function openChatRoom(roomNoParam, senderUser, receiveUser) {
    roomNo = roomNoParam;  // 방 번호 저장

    // 현재 로그인한 사용자와 senderUser/receiveUser를 비교해서 상대방 이름을 설정
    var chatPartner = (senderUser === username) ? receiveUser : senderUser;

    // 채팅방 제목을 상대방 이름으로 설정
    $('#chatRoomModalLabel').text(chatPartner + "님과의 채팅");

    $.ajax({
        url: '/chat/getChatRoom',
        type: 'GET',
        data: { roomNo: roomNo },
        beforeSend: function(xhr) {
            xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
        },
        success: function(response) {
            if (response.length === 0) {
                $('#chatContent').html('<p>채팅 기록이 없습니다. 메시지를 입력하세요!</p>');
            } else {
                var messagesHtml = '';
                response.forEach(function(msg) {
                    var time = new Date(msg.msgDate).toLocaleTimeString();
                    var readStatus = (msg.readYn === 0) ? "<span class='read-status'>읽음</span>" : "<span class='read-status'>1</span>";

                    if (msg.senderUser === "${prc.username}") {
                        messagesHtml += 
                            "<div class='chat-message right'>" +
                                "<div class='message-meta'>" +
                                    "<span class='username-right'>" + msg.senderUser + "</span>" +
                                "</div>" +
                                "<p>" + msg.msgContent + "</p>" +
                                "<span class='message-time'>" + time + "</span>" +
                                readStatus +  // 읽음 상태 표시
                            "</div>";
                    } else {
                        messagesHtml += 
                            "<div class='chat-message left'>" +
                                "<div class='message-meta'>" +
                                    "<span class='username-left'>" + msg.senderUser + "</span>" +
                                "</div>" +
                                "<p>" + msg.msgContent + "</p>" +
                                "<span class='message-time'>" + time + "</span>" +
                            "</div>";
                    }
                });
                $('#chatContent').html(messagesHtml);
            }

            // 읽음 상태 주기적으로 확인하는 함수 시작
            startCheckReadStatus();
            
            $('#chatRoomModal').modal('show');
            connectWs();  // WebSocket 연결
        },
        error: function() {
            alert('채팅방 데이터를 가져오는 중 오류가 발생했습니다.');
        }
    });
}



// 주기적으로 읽음 상태를 확인하는 함수
function startCheckReadStatus() {
    checkReadStatusInterval = setInterval(function() {
        updateReadStatus(roomNo);
    }, 3000);  // 3초마다 읽음 상태 확인
}

// WebSocket 연결
function connectWs() {
    if (socket !== null) {
        console.log("이미 WebSocket이 연결되어 있습니다.");
        return;
    }

    var ws = new SockJS("/chat");

    ws.onopen = function() {
        console.log('WebSocket 연결 성공');
        
        // 채팅방에 접속하면 즉시 읽음 처리
        updateReadStatus(roomNo);  // 읽음 처리 요청
    };

    ws.onmessage = function(event) {
        var receivedMessage = event.data.split(":");
        var sender = receivedMessage[0] || "알 수 없는 사용자";
        var message = receivedMessage[1] || "메시지 없음";
        var time = new Date().toLocaleTimeString();
        var readYn = receivedMessage[2] || 1;  // 읽음 상태 (0: 읽음, 1: 안 읽음)

        // 내 메시지에만 읽음 여부를 표시
        if (sender === "${prc.username}") {
            var readStatusHtml = (readYn == 0) ? "<span class='read-status'>읽음</span>" : "<span class='read-status'>1</span>";
        } else {
            var readStatusHtml = "";  // 상대방 메시지에는 읽음 상태 표시 없음
        }

        var messageHtml = 
            "<div class=\"chat-message " + (sender === "${prc.username}" ? 'right' : 'left') + "\">" +
                "<div class=\"message-meta\">" +
                    "<span class=\"" + (sender === "${prc.username}" ? 'username-right' : 'username-left') + "\">" + sender + "</span>" +
                "</div>" +
                "<p>" + message.trim() + "</p>" +  // 메시지 표시 시 공백 제거
                "<span class=\"message-time\">" + readStatusHtml + " " + time + "</span>" +
            "</div>";

        $('#chatContent').append(messageHtml);
        $('#chatContent').scrollTop($('#chatContent').prop("scrollHeight"));


        // 상대방이 메시지를 읽었는지 확인
        if (sender !== "${prc.username}") {
            updateReadStatus(roomNo);  // 상대방이 메시지를 읽었을 때 읽음 상태 업데이트
        }
    };

    ws.onclose = function() {
        console.log('WebSocket 연결 종료');
        socket = null;
    };

    socket = ws;
}

// 서버에 읽음 상태 요청
function updateReadStatus(roomNo) {
    $.ajax({
        url: '/chat/updateReadStatus',
        type: 'POST',
        data: { roomNo: roomNo },
        beforeSend: function(xhr) {
            xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
        },
        success: function() {
            console.log("읽음 처리 완료");

            // 읽음 처리 후 서버에서 확인한 메시지를 다시 불러오기
            refreshMessages(roomNo); // 메시지 UI 업데이트 함수
        },
        error: function() {
            console.log("읽음 처리 중 오류 발생");
        }
    });
}
function setDeleteButtonHandlers() {
    $('.chatDel').off('click').on('click', function() {
        var roomNo = $(this).closest('tr').find('.roomNo').val();
        var senderUser = $(this).closest('tr').find('.senderUser').val();
        var receiveUser = $(this).closest('tr').find('.receiveUser').val();

        // 삭제 확인창 표시
        Swal.fire({
            title: '채팅방을 나가시겠습니까?',
            icon: 'error',
            showCancelButton: true,
            confirmButtonColor: 'white',
            cancelButtonColor: 'white',
            confirmButtonText: '예',
            cancelButtonText: '아니오'
        }).then((result) => {
            if (result.isConfirmed) {
                // 사용자가 "예"를 누르면 AJAX 요청 실행
                $.ajax({
                    url: '/chat/byeChat',
                    type: 'POST',
                    data: { 
                        roomNo: roomNo,
                        senderUser: senderUser,
                        receiveUser: receiveUser
                    },
                    beforeSend: function(xhr) {
                        xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                    },
                    success: function(response) {
                        if (response === 'success') {
                            Toast.fire({
                                icon: 'success',
                                title: '채팅방을 나가셨습니다.'
                            }).then(() => {
                                location.reload();  // 페이지 새로고침
                            });
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: '오류',
                                text: '삭제에 실패했습니다.'
                            });
                        }
                    }
                });
            }
        });
    });
}

// 메시지 상태를 새로고침하는 함수
function refreshMessages(roomNo) {
    $.ajax({
        url: '/chat/getChatRoom',  
        type: 'GET',
        data: { roomNo: roomNo },
        success: function(response) {
            $('#chatContent').html(''); 
            var messagesHtml = '';
            response.forEach(function(msg) {
                var time = new Date(msg.msgDate).toLocaleTimeString();

                // 내가 보낸 메시지에 대해서만 읽음 상태를 처리
                if (msg.senderUser === "${prc.username}") {
                    var readStatus = (msg.readYn === 1) ? "<span class='read-status'>1</span>" : "";  
                    messagesHtml += 
                        "<div class='chat-message right'>" +
                            "<div class='message-meta'>" +
                                "<span class='username-right'>" + msg.senderUser + "</span>" +
                            "</div>" +
                            "<p>" + msg.msgContent + "</p>" +
	                       "<span class='message-time send'>" + readStatus + " " + time + "</span>" +
                        "</div>";
                } else {
                    // 상대방 메시지에는 읽음 상태 표시 안 함
                    messagesHtml += 
                        "<div class='chat-message left'>" +
                            "<div class='message-meta'>" +
                                "<span class='username-left'>" + msg.senderUser + "</span>" +
                            "</div>" +
                            "<p>" + msg.msgContent + "</p>" +
                            "<span class='message-time come'>" + time + "</span>" +
                        "</div>";
                }
            });
            $('#chatContent').html(messagesHtml);  
        },
        error: function() {
            alert('메시지를 불러오는 중 오류가 발생했습니다.');
        }
    });
}
// 페이지 로드 후 삭제 버튼 핸들러 설정
setDeleteButtonHandlers();

$('.chatDel').on('click', function() {
    var roomNo = $(this).closest('tr').find('.roomNo').val();
    var senderUser = $(this).closest('tr').find('.senderUser').val();
    var receiveUser = $(this).closest('tr').find('.receiveUser').val();
    
    Swal.fire({
        title: '채팅방을 나가시겠습니까?',
        icon: 'error',
        showCancelButton: true,
        confirmButtonColor: 'white',
        cancelButtonColor: 'white',
        confirmButtonText: '예',
        cancelButtonText: '아니오'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: '/chat/byeChat',
                type: 'POST',
                data: { 
                    roomNo: roomNo,
                    senderUser: senderUser,
                    receiveUser: receiveUser
                },
                beforeSend: function(xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function(response) {
                    if (response === 'success') {
                        Toast.fire({
                            icon: 'success',
                            title: '채팅방을 나가셨습니다.'
                        }).then(() => {
                            location.reload();  // 페이지 새로고침
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: '오류',
                            text: '삭제에 실패했습니다.'
                        });
                    }
                }
            });
        }
    });
});



// 메시지 전송
$('#send-btn').on('click', function() {
    var message = $('#chatMessage').val().trim();  // 공백 제거
    if (message !== "") {  // 공백만 있는 경우 전송 안 함
        var fullMessage = roomNo + ":" + message;
        socket.send(fullMessage);  // 메시지 전송
        $('#chatMessage').val('');  // 입력창 초기화
    } else {
        console.log("공백 메시지는 전송되지 않습니다.");  // 디버깅용 메시지
    }
});



// Enter 키로 메시지 전송 처리 (Shift + Enter로 줄바꿈 허용)
$('#chatMessage').on('keypress', function(e) {
    if (e.which === 13 && !e.shiftKey) {  // Enter 키 
        e.preventDefault();
        $('#send-btn').click(); 
    }
});


</script>
