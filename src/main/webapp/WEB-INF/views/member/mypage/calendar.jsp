<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags"
	prefix="sec"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<sec:authorize access="isAuthenticated()">
	<sec:authentication property="principal.memVO" var="priVO" />
</sec:authorize>
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/resources/css/member/calendar.css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/alert.css" />
<script
	src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<script type="text/javascript" src="/resources/js/sweetalert2.js"></script>
 <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js'></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script>
<link rel="stylesheet" href="https://unpkg.com/tippy.js@6/dist/tippy.css" />
<script src="https://unpkg.com/@popperjs/core@2"></script>
<script src="https://unpkg.com/tippy.js@6"></script>
<script>
let YrModal, calendarEl, mySchStart, mySchEnd, mySchTitle, mySchAllday, mySchBColor, mySchFColor;
let calendar;

var Toast = Swal.mixin({
	toast: true,
	position: 'center',
	showConfirmButton: false,
	timer: 3000
	});

//일정 등록 함수
function fCalAdd() {

    if (!mySchTitle.value) {
        alert("제목을 입력해주세요.");
        mySchTitle.focus();
        return;
    }
    
    let bColor = mySchBColor.value;
    let fColor = mySchFColor.value;
    if (fColor == bColor) {
        bColor = "black";
        fColor = "yellow";
    }
    let event = {
        start: mySchStart.value,
        end: mySchEnd.value,
        title: mySchTitle.value,
        allDay: mySchAllday.checked,
        backgroundColor: bColor,
        textColor: fColor
    };
    
 	// AJAX 요청으로 서버에 일정 저장
    $.ajax({
        url: '/member/saveEvent', // 서버의 URL
        type: 'POST',
         contentType: 'application/json',
        data: JSON.stringify(event),
        beforeSend:function(xhr){
			xhr.setRequestHeader("${_csrf.headerName}","${_csrf.token}");
		},
        success: function(response) {
        	Toast.fire({
				icon:'success',
				title:'등록 성공'
			});
            updateScheduleList(); 
            fMClose();
            console.log("Event added:", event);
        },
        error: function(xhr, status, error) {
        	Toast.fire({
				icon:'error',
				title:'등록 실패'
			});
            console.error("Error saving event:", xhr.status, xhr.responseText);
        }
    });
//       calendar.addEvent(event);
//     console.log("Event added:", event);
}

function formatDate(dateString) {
    const date = new Date(dateString);
    
    // 날짜 형식 설정
    const options = { month: '2-digit', day: '2-digit', weekday: 'short' }; 
    const formattedDate = date.toLocaleDateString('ko-KR', options);
    
    // 요일을 괄호로 감싸고 날짜를 "MM.DD(요일)" 형식으로 조합
    const [month, day] = formattedDate.split('.');
    const weekday = date.toLocaleDateString('ko-KR', { weekday: 'short' });

    return `\${month}.\${day}(\${weekday})`;
}

//일정 업데이트 함수
function updateScheduleList() {
    $.ajax({
        url: '/member/getScheduleList', // 일정 목록을 가져오는 서버 URL
        type: 'GET',
        success: function(scheduleList) {
        	console.log(scheduleList);
            // 기존 일정 목록을 비우고 새로운 일정으로 업데이트
            $('#scheduleContent').empty();
            $('.sdlistClass').remove();
         // 기존의 모든 이벤트를 클리어 (선택 사항)
            //calendar.removeAllEvents(); 
         
            if (scheduleList.length > 0) {
                $.each(scheduleList, function(index, scheduleVO) {
                	const startDate = formatDate(scheduleVO.schdlBgndes);
                    const endDate = formatDate(scheduleVO.schdlEnddes);
                    
                 // 이벤트 추가
                 	if (!calendar.getEventById(scheduleVO.schdlNo)) {
	                    calendar.addEvent({
	                        id: scheduleVO.schdlNo, // ID
	                        title: scheduleVO.schdlTtl, // 제목
	                        start: scheduleVO.schdlBgndes, // 시작 시간
	                        end: scheduleVO.schdlEnddes, // 종료 시간
	                        allDay: scheduleVO.schdlAlldayYn === 'Y', // 하루종일 여부
	                        backgroundColor: scheduleVO.schdlBackColor, // 배경색
	                        textColor: scheduleVO.schdlTextColor // 글자색
	                    });
                 	};

                    $('#scheduleContent').append(`
                        <div class="sdlistClass">
                            <div class="sclso1">
                                <input type="color" class="schaduleColor" disabled value="\${scheduleVO.schdlBackColor}">
                            </div>
                            <div class="pblso2">
                                <div>
                                    <p class="fbigtt"><a onclick="deleteEvent(String(\${scheduleVO.schdlNo}))">\${scheduleVO.schdlTtl}</a></p>
                                </div>
                            </div>
                            <div class="pbl">
	                            <div class="fsmall">\${startDate}부터</div>
	                            <div class="fsmall">\${endDate}까지</div>
                            </div>
                            <input type="hidden" id="schdlNo" value="\${scheduleVO.schdlNo}">
                        </div>
                    `);
                 	
                });
            }
        },
        error: function(xhr, status, error) {
            console.error("Error fetching schedule list:", xhr.status, xhr.responseText);
        }
    });
}
//일정 삭제 함수
 function deleteEvent(eventId) {
	Swal.fire({
		  title: '해당 일정을 삭제하시겠습니까?',
		  icon: 'error',
		  showCancelButton: true,
		  confirmButtonColor: 'white',
		  cancelButtonColor: 'white',
		  confirmButtonText: '예',
		  cancelButtonText: '아니오',
		  reverseButtons: false, // 버튼 순서 거꾸로
		}).then((result) => {
		  if (result.isConfirmed) {
			  $.ajax({
		            url: '/member/deleteEvent',
		            type: 'DELETE',
		            contentType: 'application/json',
		            data: JSON.stringify({ id: eventId }),
		            beforeSend: function(xhr) {
		                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
		            },
		            success: function(result) {
		                calendar.getEventById(eventId)?.remove();
		                updateScheduleList();
		                console.log("Event deleted:", response);
		            },
		            error: function(xhr, status, error) {
		                console.error("Error deleting event:", xhr.status, xhr.responseText);
		            }
		        });
		  }
		});

}

function fMClose() {
    yrModal.style.display = "none";
    mySchStart.value = "";
    mySchEnd.value = "";
    mySchTitle.value = "";
    mySchAllday.checked = false;
    mySchBColor.value = "#000000";
    mySchFColor.value = "#ffffff";
};

document.addEventListener('DOMContentLoaded', function() {
	YrModal = document.querySelector("#yrModal");
    calendarEl = document.querySelector('#calendar');
    mySchStart = document.querySelector("#schStart");
    mySchEnd = document.querySelector("#schEnd");
    mySchTitle = document.querySelector("#schTitle");
    mySchAllday = document.querySelector("#allDay");
    mySchBColor = document.querySelector("#schBColor");
    mySchFColor = document.querySelector("#schFColor");
    
    const headerToolbar = {
        left: 'prevYear,prev,next,nextYear today',
        center: 'title',
        right: 'dayGridMonth,dayGridWeek,timeGridDay'
    }

//     서버에서 전달된 이벤트 데이터를 JS에서 사용할 수 있도록 변환
   let eventsFromServer = [
	   <c:forEach items="${calendarList}" var="PbancVO">
        	{   title: "${PbancVO.pbancTtl}",
			    start: "${PbancVO.pbancDdlnDt}",
			    end: "${PbancVO.pbancDdlnDt}",
			    allDay: true,
			    backgroundColor: "rgba(44, 207, 195, 0.2)",
			    textColor: "black" 
            },
        </c:forEach>
        <c:forEach items="${calendarList2}" var="scheduleVO">
        	{	
        		id: "${scheduleVO.schdlNo}",
            	title: "${scheduleVO.schdlTtl}",
			    start: "${scheduleVO.schdlBgndes}",
			    end: "${scheduleVO.schdlEnddes}",
			    allDay: ${scheduleVO.schdlAlldayYn == 'Y' ? 'true' : 'false'},
			    backgroundColor: "${scheduleVO.schdlBackColor}",
			    textColor: "${scheduleVO.schdlTextColor}" 
            },
        </c:forEach>
    ];

    const today = new Date();
    const firstDayOfCurrentMonth = new Date(today.getFullYear(), today.getMonth(), 1); // 현재 월의 첫 번째 날

    const calendarOption = {
        width : '1100px',
        height: '600px',
        expandRows: true,
        slotMinTime: '09:00',
        slotMaxTime: '18:00',
        headerToolbar: headerToolbar,
        initialView: 'dayGridMonth',
        initialDate: firstDayOfCurrentMonth, // 현재 월의 첫 번째 날을 초기 날짜로 설정
        locale: 'ko',
        selectable: true,
        selectMirror: true,
        navLinks: true,
//         weekNumbers: true,
        editable: true,
        dayMaxEventRows: true,
        nowIndicator: true,
        events: eventsFromServer,  // 서버에서 가져온 이벤트 리스트 사용
        eventSources: [
            './commonEvents.json',  // Ajax 요청 URL임에 유의!
            './KYREvents.json',
            './SYREvents.json'
        ]
    }

    calendar = new FullCalendar.Calendar(calendarEl, calendarOption);
    calendar.render();
	
 	// 캘린더 이벤트 등록
    calendar.on("eventAdd", info => console.log("Add:", info));
    calendar.on("eventChange", info => console.log("Change:", info));
    calendar.on("eventRemove", info => console.log("Remove:", info));
    calendar.on("eventClick", function(info) {
        const eventId = info.event.id;
        deleteEvent(eventId);
    });
    
    calendar.on("eventMouseEnter", info => console.log("eEnter:", info));
    calendar.on("eventMouseLeave", info => console.log("eLeave:", info));
    calendar.on("dateClick", info => console.log("dateClick:", info));
    
    calendar.on("select", info => {
        mySchStart.value = info.startStr;
        mySchEnd.value = info.endStr;
        YrModal.style.display = "block";
    });
    
    
    
     updateScheduleList();
    
});

$(function(){
	
});
function alerttext(){
	alert("로그인 후 이용하세요.");
	location.href="/security/login";
}
function openModal() {
    document.querySelector("#yrModal").style.display = "block";
}
</script>
<body>
 <sec:authentication property="principal" var="prc" />
 <!-- 모달 창 -->
			<div id="yrModal">
				<div id="cont" style="text-align: center;">
					<div id="closeModal">
						<button onclick="fMClose()" class="close"></button>
					</div>
					<h4>일정 등록하기</h4>
					<br>
					<div id="ModalContent">

						<label id="Caltitle">제목</label> 
						<input type="text" id="schTitle" value="">

						<div class="blockDiv">
							<label id="start">시작일</label>
							<input type="datetime-local" id="schStart" value="">
						</div>
						<div class="blockDiv">
							<label id="end">종료일</label>
							<input type="datetime-local" id="schEnd" value="">
						</div>
						<label style="margin-right:5px;">하루종일</label> <input type="checkbox" id="allDay"><br>
						<div class="flexDiv">
								<label id="back">배경색</label>
								<input type="color" id="schBColor" class="colorCss" value="">
								<label id="font">글자색</label>
								<input type="color" id="schFColor" class="colorCss" value="">

						</div>
					</div>
					<button id="add" onclick="fCalAdd()">등록</button>
					<br>
				</div>
			</div>
	<!-- 달력시작 -->
	<div class="container" style="position: relative; bottom: 35px;">
		<p id="h3">스크랩/일정 캘린더</p>
		<!-- 캘린더 영역 -->
		<div id="Wrapper">
			<div id='calendar'></div>
		</div>
		<div id="flexDiv">
		<div id="pbancmenu">
			<div id="pbanctitle">
				<h5>내가 스크랩한 공고</h5>
				<c:if test="${prc ne 'anonymousUser'}">
					<a href="/member/scrap?mbrId=${memVO.mbrId}">더보기 ></a>
				</c:if>
				<c:if test="${prc eq 'anonymousUser'}">
					<a onClick="alerttext()">더보기></a>
				</c:if>
			</div>
			<div id="pbancex">
				<div id="pbanclist">
					<c:if test="${prc eq 'anonymousUser'}">
						<p id="notlogin">로그인 후 이용 가능합니다.</p>
					</c:if>
					<c:if test="${prc ne 'anonymousUser'}">
						<c:if test="${not empty scrapList}">
							<c:forEach var="pbancVO" varStatus="stat" items="${scrapList}">
								<div id="pblist">
									<div class="pblso">
										<div class="fbig">${pbancVO.entNm}</div>
									</div>

									<div class="pblso2">
										<div>
											<p class="fbigtt">
												<a target="_blank" href="/enter/pbancDetail?pbancNo=${pbancVO.pbancNo}">${pbancVO.pbancTtl}</a>
											</p>
										</div>
									</div>

									<div class="pblso1">
										<div class="fsmall">
											<c:if test="${pbancVO.pbancRprsrgnNm != '세종' && pbancVO.pbancRprsrgnNm != '전국'}">
	                   				 			${pbancVO.pbancRprsrgnNm}
	                						</c:if>
												${pbancVO.pbancCityNm}</div>
										<div class="fsmall">${pbancVO.pbancWorkstleNm}</div>
										<div class="fsmall">${pbancVO.pbancAplctEduCdNm}↑</div>
									</div>

									<div class="pbl">
										<div class="fsmall">${pbancVO.pbancDlnDt}까지</div>
										<div class="fsmall">${pbancVO.pbancBeforeWrt}일전등록</div>
									</div>
								</div>
							</c:forEach>
						</c:if>
						<c:if test="${empty scrapList}">
							<p>스크랩한 공고가 없습니다.</p>
						</c:if>
					</c:if>
				</div>
			</div>
		</div>
		<!-- 나의 일정 시작 -->
		<div id="scheduleBox">
			<div id="scheduleTitle">
				<h5>나의 일정</h5>
				<c:if test="${prc ne 'anonymousUser'}">
					<a href="javascript:void(0);" onclick="openModal()">추가 ></a>
				</c:if>
				<c:if test="${prc eq 'anonymousUser'}">
					<a onClick="alerttext()">추가
						></a>
				</c:if>
			</div>
			<div id="scheduleEx">
				<div id="scheduleList">
					<c:if test="${pageContext.request.userPrincipal == null}">
						<p id="notlogin">로그인 후 이용 가능합니다.</p>
					</c:if>
					<c:if test="${pageContext.request.userPrincipal != null}">
						<c:if test="${not empty scheduleList}">
							<div id="scheduleContent">
							</div>
						</c:if>
						<c:if test="${empty scheduleList}">
							<p>등록한 일정이 없습니다.</p>
						</c:if> 
					</c:if>
				</div>
			</div>
		</div>
		</div><!-- flexDiv -->
	</div>