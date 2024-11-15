<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<sec:authorize access="isAuthenticated()">
	<sec:authentication property="principal.memVO" var="memVO" />
</sec:authorize>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script> 
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/alert.css" />
<script type="text/javascript" src="/resources/js/sweetalert2.js"></script>
<!-- 외주 css 파일 -->
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/resources/css/outsou/edit.css" />
<!-- ckeditor -->
<script type="text/javascript" src="/resources/ckeditor5/ckeditor.js"></script> 
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>

<script type="text/javascript">
var Toast = Swal.mixin({
    toast: true,
    position: 'center',
    showConfirmButton: false,
    timer: 3000
  });
//이미지 처리 함수 
function HandleImg(e, targetElement) {
    let files = e.target.files; // 선택한 파일들
    let fileArr = Array.prototype.slice.call(files); // 배열로 변환
    let accumStr = "";

    fileArr.forEach(function(f) {
        // 이미지가 아니면
        if (!f.type.match("image.*")) {
            alert("이미지 확장자만 가능합니다.");
            return;
        }

        // 이미지일 경우 처리
        let reader = new FileReader();
        reader.onload = function(e) {
            accumStr += "<img src='" + e.target.result + "' style='width: 220px; height:180px; border: 1px solid #CED4DA;'>";
            $(targetElement).html(accumStr); // targetElement로 지정된 곳에 이미지 표시
        };
        reader.readAsDataURL(f);
    });
}


//1차 카테고리 선택에 따른 2차 카테고리 가져오기 함수
function loadCategory2(category1) {
    console.log("category1 : ", category1);

    // 1차 카테고리 값이 'OUCL01'인 경우에 특정 폼 그룹을 보여주고 숨김
    if (category1 == 'OULC01') {
        $(".form-group4").show(); // IT
        $(".form-group3").hide(); // 자기소개서
        $(".category2_3").show(); // 작업기간
        $(".category2_4").show(); // 작업기간
        $(".category2_5").show(); // 작업기간
    } else {
        $(".form-group4").hide(); // IT
        $(".form-group3").show(); // 자기소개서
        $(".category2_3").hide(); // 작업기간
        $(".category2_4").hide(); // 작업기간
        $(".category2_5").hide(); // 작업기간
    }

    // 보낼 데이터 (JSON 형식)
    let data = {
        "comCode": category1 // 선택한 1차 카테고리 값을 'comCode'로 서버에 보냄
    };

    // 2차 카테고리를 가져오기 위한 AJAX 요청 시작
    $.ajax({
        url: "/outsou/category2",  // 2차 카테고리 데이터를 가져오는 컨트롤러 메소드의 URL
        contentType: "application/json;charset=utf-8",  // 보내는 데이터의 타입
        data: JSON.stringify(data),  // JSON 데이터를 문자열로 변환해서 전송
        type: "POST",  // POST 요청 방식
        dataType: "json",  // 서버에서 받을 데이터 타입을 JSON으로 지정
        beforeSend: function(xhr) {
            // CSRF 토큰 전송 (보안 관련)
            xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
        },
        success: function(result) {
            // 서버에서 받은 2차 카테고리 데이터를 처리
            console.log("result : ", result);

            // 2차 카테고리 select 박스를 초기화
            $("#outordMlsfc").html("<option value='' selected disabled>선택해주세요</option>");

            // 서버에서 받은 데이터로 2차 카테고리 옵션을 동적으로 생성하여 추가
            let savedMlsfc = $("#savedOutordMlsfc").val(); // 저장된 2차 카테고리 값
            $.each(result, function(idx, codeVO) {
            	let selected = (codeVO.comCode === savedMlsfc) ? "selected" : "";
                let option = "<option value='" + codeVO.comCode + "' " + selected + ">" + codeVO.comCodeNm + "</option>";
                $("#outordMlsfc").append(option);
            });
        },
        error: function(error) {
            console.log("Error:", error);  // 에러 처리
        }
    });
}


$(function(){
	console.log("개똥이");
	
	//이미지  미리보기 시작///
	$("#mainFile").on('change', function(e) {
    HandleImg(e, "#mainpImg");
	});
	
	$("#detailFile").on('change', function(e) {
	    HandleImg(e, "#detpImg");
	});
	//이미지 미리보기 끝///

	
	//1차 선택에 따라 2차 카테고리 가져오기 시작 
	// select box에서 1차 카테고리 선택 시 호출
	$("select[name='outordLclsf']").on("change", function() {
	    let category1 = $(this).val(); // 선택한 1차 카테고리 값
	    loadCategory2(category1); // 1차 카테고리 값에 따른 2차 카테고리 로드
	});
	
	// 페이지 로드 시 기존에 저장된 1차 카테고리가 있는 경우에 호출
	$(document).ready(function() {
	    let savedCategory1 = "${outsouVO.outordLclsf}"; // 서버에서 가져온 1차 카테고리 값
	    console.log("savedCategory1->",savedCategory1);
	        loadCategory2(savedCategory1); // 저장된 1차 카테고리 값에 따른 2차 카테고리 로드
	});

	//1차 선택에 따라 2차 카테고리 가져오기 끝 

	
	//카워드 추가하는 부분 시작 
    // 키워드 추가 기능
    var maxKeywords = 5;

    // 키워드 추가 기능
    $(".Keyword__add").on("click", function() {
        let keyword = $("input[name='kwtext']").val().trim();  // 키워드 입력 필드에서 값 가져오기
        let currentKeywordsCount = $('.keywordItem').length;  // 현재 추가된 키워드 개수 확인

        if (currentKeywordsCount >= maxKeywords) {
        	Toast.fire({
                icon: 'error',
                title: '최대 ' + maxKeywords + '개의 키워드만 추가할 수 있습니다'
            });
            return;
        }

        if (keyword !== "") {
	        // 중복 키워드 방지
	        let existingKeywords = $('.keywordItem').map(function() {
	            return $(this).find('input[name="kwrdNm"]').val();
	        }).get();
	
	        if (existingKeywords.includes(keyword)) {
	        	Toast.fire({
	                icon: 'error',
	                title: '중복된 키워드입니다.'
	            });
	            return;
	        }
            // 새로운 키워드 추가
            var keywordElement = '<div class="keywordItem" style="margin: 5px;">' +
                                 '<input type="text" name="kwrdNm" value="' + keyword + '" style="display: none;"/>' +
                                 '<span class="kwrdNm">' + keyword + '</span>' +
                                 '<button type="button" class="deleteKeyword">x</button>' +
                                 '</div>';
            $('.KeywordtextAdd').append(keywordElement);
            $("input[name='kwtext']").val('');  // 입력 필드 초기화
        } else {
	        alert('키워드를 입력해주세요.');
	    }
    });

    // 키워드 삭제 기능
    $(document).on('click', '.deleteKeyword', function() {
        $(this).parent('.keywordItem').remove();  // 키워드 삭제
    });

	//카워드 추가하는 부분 끝

  //언어, 클라우드, 데이터베이스 부분 어떤 걸 선택했느지 보기 시작 
	//언어
    $('#osDevalVO\\.srvcLangCd').on('change', function() {
        let selected = $(this).find('option:selected').map(function() {
            return $(this).text(); // 선택된 옵션의 텍스트 가져오기
        }).get().join(', ');

        if (selected) {
            $("#Lang").text(selected).show(); // 선택한 항목을 표시하고 영역을 보여줌
        } else {
            $("#Lang").hide(); // 선택된 값이 없으면 숨김
        }
    });
	
    $('#osDevalVO\\.srvcDatabaseCd').on('change', function() {
        let selected = $(this).find('option:selected').map(function() {
            return $(this).text(); // 선택된 옵션의 텍스트 가져오기
        }).get().join(', ');

        if (selected) {
            $("#Database").text(selected).show(); // 선택한 항목을 표시하고 영역을 보여줌
        } else {
            $("#Database").hide(); // 선택된 값이 없으면 숨김
        }
    });
    
    $('#osDevalVO\\.srvcCludCd').on('change', function() {
        let selected = $(this).find('option:selected').map(function() {
            return $(this).text(); // 선택된 옵션의 텍스트 가져오기
        }).get().join(', ');

        if (selected) {
            $("#Clud").text(selected).show(); // 선택한 항목을 표시하고 영역을 보여줌
        } else {
            $("#Clud").hide(); // 선택된 값이 없으면 숨김
        }
    });
	//언어, 클라우드, 데이터베이스 부분 어떤 걸 선택했느지 보기 끝

	//취소하기 시작
	$(".cancel").on("click", function() {
	    Swal.fire({
	        title: '취소하시겠습니까? \n 수정한 내용은 저장되지 않습니다.',
	        icon: 'question',
	        showCancelButton: true,
	        confirmButtonColor: 'white',
	        cancelButtonColor: 'white',
	        confirmButtonText: '예',
	        cancelButtonText: '아니오'
	    }).then((result) => {
	        // 사용자가 "예"를 선택했을 경우에만 동작
	        if (result.isConfirmed) {
	            // 외주 번호를 URL 파라미터로 함께 전달
	            let outordNo = '${outsouVO.outordNo}';  // JSP에서 외주 번호를 올바르게 전달받아야 합니다.
	            window.location.href = "/outsou/detail?outordNo=" + outordNo;
	        }
	    });
	});
	//취소하기 끝
	

	
	//수정하기 
	$("#savebtn").on("click", function(event) {
		event.preventDefault(); // 기본 폼 전송 방지
		//유효성 검사 시작
		//제목 검사
		if($("#outordTtl").val().trim().length < 1 || $("#outordTtl").val().trim().length > 30 ){
			Toast.fire({
		        icon: 'warning',
		        title: '제목을 입력해주세요.'
		    });
			$('#outordTtl').focus();
		    event.preventDefault();
		    return false;
		}
		
		// 대분류 -> select box
		if (!$("#outordLclsf").val()) {  // 선택된 값이 없으면
		    Toast.fire({
		        icon: 'warning',
		        title: '대분류를 선택해주세요'
		    });
		    $('#outordLclsf').focus();
		    event.preventDefault();
		    return false;
		}
		
		
		//중분류 
		if(!$("#outordMlsfc").val() ){
		   Toast.fire({
		        icon: 'warning',
		        title: '중분류를 선택해주세요'
		    });
		    $('#outordMlsfc').focus();
		    event.preventDefault();
		    return false;
		}
		
		//금액
		if ($("#outordAmt").val().trim() < 10000) {
		    Toast.fire({
		        icon: 'warning',
		        title: '금액은 10,000원 이상입력해주세요.'
		    });
		    $('#outordAmt').focus();
		    event.preventDefault();
		    return false;
		}
		
		//서비스 설명
		if (!$("#outordExpln").val()) {
		    Toast.fire({
		        icon: 'warning',
		        title: '서비스 설명을 입력해주세요.'
		    });
		    $('#outordExpln').focus();
		    event.preventDefault();
		    return false;
		}
		
		//서비스 제공절차
		if (!$("#outordProvdprocss").val()) {
		    Toast.fire({
		        icon: 'warning',
		        title: '서비스 제공절차를 입력해주세요.'
		    });
		    $('#outordProvdprocss').focus();
		    event.preventDefault();
		    return false;
		}
		
		//환불규정
		if (!$("#outordRefndregltn").val()) {
		    Toast.fire({
		        icon: 'warning',
		        title: '환불규정을 입력해주세요.'
		    });
		    $('#outordRefndregltn').focus();
		    event.preventDefault();
		    return false;
		}
		
		
		//메인 이미지
		if ($("#mainFile")[0].files.length === 0 && !$("#mainpImg img").attr('src')) { 
		    Toast.fire({
		        icon: 'warning',
		        title: '메인이미지를 등록해주세요.'
		    });
		    $('#mainFile').focus();
		    event.preventDefault();
		    return false;
		}
		
		//작업전 요청사항
		if (!$("#outordDmndmatter").val()) {
		    Toast.fire({
		        icon: 'warning',
		        title: '환불규정을 입력해주세요.'
		    });
		    $('#outordDmndmatter').focus();
		    event.preventDefault();
		    return false;
		}
		//유효성 검사 끝
	    // 수정 확인 메시지
	    Swal.fire({
	        title: '수정하시겠습니까?',
	        icon: 'question',
	        showCancelButton: true,
	        confirmButtonColor: 'white',
	        cancelButtonColor: 'white',
	        confirmButtonText: '예',
	        cancelButtonText: '아니오'
	    }).then((result) => {
	    	if (result.isConfirmed) {
	            // 수정 확인 시 폼 전송
	            $("#updateForm").submit();  // 제출할 폼을 확인하세요.
	            Toast.fire({
	                icon: 'success',
	                title: '수정이 완료되었습니다.'
	            });
	
	            // 3초 후 페이지 이동
	            setTimeout(function() {
	                let outordNo = '${outsouVO.outordNo}';  // JSP에서 넘겨오는 데이터가 맞는지 확인하세요.
	                window.location.href = "/outsou/detail?outordNo=" + outordNo;
	            }, 3000);
	        } else {
	            // 수정 취소 시 버튼 다시 활성화
	            $("#savebtn").prop('disabled', false);
	            Toast.fire({
	                icon: 'error',
	                title: '수정이 취소되었습니다.'
	            });
		    }
		});
	});
	//수정하기 끝
	
	
})//function 끝

$(document).ready(function() {
    let outordTtl = $("#outordTtl").val() || ""; // 제목 입력란의 값을 가져오거나, 값이 없으면 빈 문자열로 설정
    let currentLength = outordTtl.length; // 제목의 현재 길이로 currentLength 초기화

    $("#charCount").text(currentLength); // 초기 글자 수 표시
    $("#outordTtl").val(outordTtl); // 제목 입력란의 값을 설정

    $("#outordTtl").on("input", function() {
        currentLength = $(this).val().length; // 사용자가 입력할 때마다 글자 수 업데이트
        $("#charCount").text(currentLength);

        if (currentLength > 30) {
            $("#warning").show();  // 글자 수가 30자를 넘으면 경고 메시지 표시
            $(this).val($(this).val().substring(0, 30));  // 입력 글자 수를 30자로 제한
            $("#charCount").text(30);  // 글자 수 30자로 고정
        } else {
            $("#warning").hide();  // 30자 이하일 경우 경고 메시지 숨김
        }
    });
});
</script>
<div class="registAll">
	<!-- 수정  정보 전체 -->
	<div class="regist">
		<div class="registTitle">
			<h2>재능 수정</h2>
		</div>
		<div class="smRegust">
			<form name="updateForm" id="updateForm"
				action="/outsou/updatePost?${_csrf.parameterName}=${_csrf.token}" method="post" enctype="multipart/form-data">
				<input type="text" name="mbrId" value="${memVO.mbrId}" style="display: none;" />
				<!-- param : ?outordNo=10 -->
				<input type="text" name="outordNo" value="${param.outordNo}" style="display: none;" />
				<!-- srvcNo=null, outordNo=null -->
				<input type="text" name="osDevalVO.srvcNo" value="${outsouVO.osDevalVO.srvcNo}" style="display: none;" />
				<input type="text" name="osDevalVO.outordNo" value="${outsouVO.osDevalVO.outordNo}" style="display: none;" />
				<input type="text" name="osClVO.srvcNo" value="${outsouVO.osClVO.srvcNo}" style="display: none;" />
				<!-- 기본정보 -->
				<div>
					<div class="GigFormInput1">
						<div class="GigFormInput_title">
							<p>기본 정보 수정</p>
						</div>
						<div class="FormInput1">
							<div class="form-group1">
								<label class="label1">제목<span class="required">*</span></label> 
								<input type="text"
										name="outordTtl" id="outordTtl" class="title_1"
										value="${outsouVO.outordTtl}" maxlength="50" 
										required />
								<div style="display: flex;">
						           <p id="countp">&nbsp;&nbsp;(&nbsp;<span id="charCount">0</span>&nbsp;/&nbsp;30&nbsp;)</p>
						        </div>
							  </div>
							   <p id="warning">글자 수가 30자를 넘었습니다!</p>

							<!-- 카테고리 form-group2 -->
							<div class="form-group2">
								<div class="form-sub-group">
									<div class="category">
										<!-- 1차 카테고리 (category1) 선택 -->
										<label class="label2_1">대분류<span class="required">*</span></label> 
										<select id="outordLclsf" name="outordLclsf" class="title_2" required >
											<option value=""   disabled>선택해주세요</option>
											<!-- DB에서 가져온 값들과 비교 -->
											    <c:forEach var="CodeVO" items="${codeGrpVOMap.get('OULC').codeVOList}">
											        <!-- 저장된 값이 있으면 해당 옵션을 기본값으로 선택 -->
											        <option value="${CodeVO.comCode}" 
											            <c:if test="${CodeVO.comCode == outsouVO.outordLclsf}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
											    </c:forEach>
										</select>
									</div>
									<div class="category">
										<!-- 2차 카테고리 (category2) 선택 -->
										<!-- DB에서 저장된 2차 카테고리 값을 input의 hidden 필드로 저장 -->
										<input type="hidden" id="savedOutordMlsfc" value="${outsouVO.outordMlsfc}" />
										<label class="label2_1">중분류<span class="required">*</span></label> 
										<select id="outordMlsfc" name="outordMlsfc" class="title_2" required>
											<option value=""  disabled>선택해주세요</option>
											        <option value="${CodeVO.comCode}" 
											            <c:if test="${CodeVO.comCode == outsouVO.outordMlsfc}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
										</select>
									</div>
								</div>
							</div>
							<!-- 카테고리 끝 -->	
							<!-- 자소서 서비스 타입 form-group3 -->
							<div class="form-group3" style="display: none;">
								<div class="form-group3_cont">
									<p>서비스 타입에 항목들을 선택 및 입력해 주세요.</p>
								</div>
								<div class="form-group3_1">
									<div class="form-sub-group">
										<div class="category">
											<label class="label2_1">직업분야</label> 
											<select id="osClVO.srvcFld"  name="osClVO.srvcFld" class="title_2" >
												<option value=""  disabled>선택해주세요</option>
												<c:forEach var="CodeVO" items="${codeGrpVOMap.get('RCCA').codeVOList}">
													<option value="${CodeVO.comCode}" 
											            <c:if test="${CodeVO.comCode == osClVO.srvcFld}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
												</c:forEach>
											</select>
										</div>
										<div class="category">
											<label class="label2_1">기업종류</label> 
											<select	 id="osClVO.srvcKnd" name="osClVO.srvcKnd" class="title_2" >
												<option value=""  disabled>선택해주세요</option>
												<c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRKN').codeVOList}">
													<option value="${CodeVO.comCode}" 
											            <c:if test="${CodeVO.comCode == osClVO.srvcKnd}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
												</c:forEach>
											</select>
										</div>
										<div class="category">
											<label class="label2_1">지원전형</label> 
											<select id="osClVO.srvcArctype" name="osClVO.srvcArctype" class="title_2" >
												<option value=""  disabled>선택해주세요</option>
												<c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRAR').codeVOList}">
													<option value="${CodeVO.comCode}" 
											            <c:if test="${CodeVO.comCode == osClVO.srvcArctype}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</div>
							</div>
							<!-- 자소서 서비스 타입 끝 -->
							<!-- 개발 서비스 타입  -->
							<div class="form-group4" style="display: none">
								<div class="form-group3_cont">
									<p>서비스 타입에 항목들을 선택 및 입력해 주세요.</p>
								</div>
								<div class="form-group4_1">
									<div class="form-sub-group">
										<div class="category">
											<label class="label2_1">기술수준<span class="required">*</span></label> 
											<select id="osDevalVO.srvcLevelCd" 
													name="osDevalVO.srvcLevelCd" class="title_2" required>
												<option value=""  disabled>선택해주세요</option>
												<c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRLE').codeVOList}">
													<option value="${CodeVO.comCode}" 
													 <c:if test="${CodeVO.comCode == outsouVO.osDevalVO.srvcLevelCd}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
												</c:forEach>
											</select>
										</div>
										<div class="category">
											<label class="label2_1">팀 규모<span class="required">*</span></label> 
											<select id="osDevalVO.srvcTeamscaleCd"
													name="osDevalVO.srvcTeamscaleCd" class="title_2" required>
												<option value=""  disabled>선택해주세요</option>
												<c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRTE').codeVOList}">
													<option value="${CodeVO.comCode}" 
											            <c:if test="${CodeVO.comCode == outsouVO.osDevalVO.srvcTeamscaleCd}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
												</c:forEach>
											</select>
										</div>
										<div class="category3">
											<label class="label2_1">개발언어</label> 
											<div>
												<div>
													<select  id="osDevalVO.srvcLangCd" 
															name="osDevalVO.srvcLangCd" class="form-control title_5" style="height: auto;"   multiple>
														<c:forEach var="osdeLangVO" items="${outsouVO.osDevalVO.osdeLangVOList}"> 
														    <!-- srvcLangCd를 쉼표로 분리하여 반복 처리 -->
														    <c:set var="langList" value="${fn:split(osdeLangVO.srvcLangCd, ',')}" />
														    <!-- CodeVO 리스트 반복 -->
														    <c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRLA').codeVOList}">
														        <option value="${CodeVO.comCode}" 
														            <c:forEach var="langCd" items="${langList}">
														                <c:if test="${CodeVO.comCode == fn:trim(langCd)}">
														                    selected
														                </c:if>
														            </c:forEach>
														        >
														            ${CodeVO.comCodeNm}
														        </option>
														    </c:forEach>
														</c:forEach> 
													</select>
												</div>
												<div id="Lang">
													<c:forEach var="Lang" items="${outsouVO.osDevalVO.osdeLangVOList}"  varStatus="status">
														<c:out value="${Lang.srvcLangNm}" />
														<c:if test="${!status.last}">, </c:if>
													</c:forEach>
												</div>
											</div>
										</div>
										<div class="category3">
											<label class="label2_1">데이터베이스</label>
											<div>
												<div>
													 <select id="osDevalVO.srvcDatabaseCd"
															name="osDevalVO.srvcDatabaseCd" class="form-control title_5"  multiple>
														<c:forEach var="osdeDatabaseVO" items="${outsouVO.osDevalVO.osdeDatabaseVOList}"> 
														    <!-- 쉼표로 분리하여 반복 처리 -->
														    <c:set var="DBList" value="${fn:split(osdeDatabaseVO.srvcDatabaseCd, ',')}" />
														    <!-- CodeVO 리스트 반복 -->
														    <c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRDB').codeVOList}">
														        <option value="${CodeVO.comCode}" 
														            <c:forEach var="DBCd" items="${DBList}">
														                <c:if test="${CodeVO.comCode == fn:trim(DBCd)}">
														                    selected
														                </c:if>
														            </c:forEach>
														        >
														            ${CodeVO.comCodeNm}
														        </option>
														    </c:forEach>
														</c:forEach> 
													</select>
												</div>
												<div id="Database">
													<c:forEach var="Database" items="${outsouVO.osDevalVO.osdeDatabaseVOList}"  varStatus="status">
														<c:out value="${Database.srvcDatabaseNm}" />
														<c:if test="${!status.last}">, </c:if>
													</c:forEach>
												</div>
											</div>
										</div>
										<div class="category3">
											<label class="label2_1">클라우드</label> 
											<div>
												<div>
													<select id="osDevalVO.srvcCludCd"
															name="osDevalVO.srvcCludCd" class="form-control title_5" multiple>
														<c:forEach var="osdeCludVO" items="${outsouVO.osDevalVO.osdeCludVOList}"> 
														    <!-- 쉼표로 분리하여 반복 처리 -->
														    <c:set var="CLudList" value="${fn:split(osdeCludVO.srvcCludCd, ',')}" />
														    <!-- CodeVO 리스트 반복 -->
														    <c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRCL').codeVOList}">
														        <option value="${CodeVO.comCode}" 
														            <c:forEach var="CludCd" items="${CLudList}">
														                <c:if test="${CodeVO.comCode == fn:trim(CludCd)}">
														                    selected
														                </c:if>
														            </c:forEach>
														        >
														            ${CodeVO.comCodeNm}
														        </option>
														    </c:forEach>
														</c:forEach> 
													</select>
												</div>
												<div id="Clud">
													<c:forEach var="Clud" items="${outsouVO.osDevalVO.osdeCludVOList}"  varStatus="status">
														<c:out value="${Clud.srvcCludNm}" />
														<c:if test="${!status.last}">, </c:if>
													</c:forEach>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
							<div class="form-group4" style="display: none">
							    <div class="form-group-3_cont">
							        <p>검색 키워드는 서비스 설명에 노출되지 않지만 검색 대상으로 사용됩니다.</p>
							        <p>동일한 키워드 중복 입력은 검색 결과와 무관합니다.</p>
							        <p>키워드는 5개까지만 입력이 가능합니다.</p>
							    </div>
							    <div class="category_2">
							        <div>
							            <label class="label2_1">검색 키워드 </label>
							        </div>
							        <div class="kwrdADDALL">
							            <div class="kwrdADD">
							                <input type="text" name="kwtext" id="kwtext" class="kwtitle_2" placeholder="키워드 입력 "/>
							            </div>
							            <button type="button" class="Keyword__add">추가</button>
							            <div class="KeywordtextAdd">
							                <!-- osKeywordVOList에서 키워드 문자열을 쉼표로 분리하여 반복 출력 -->
							                <c:if test="${outsouVO.osKeywordVOList != null}">
							                    <c:forEach var="keywordVO" items="${outsouVO.osKeywordVOList}">
							                        <!-- 키워드 문자열을 쉼표로 분리하여 반복 처리 -->
							                        <c:set var="keywordArray" value="${fn:split(keywordVO.kwrdNm, ',')}" />
							                        <c:forEach var="keyword" items="${keywordArray}">
							                            <div class="keywordItem" style="margin: 5px;">
							                                <!-- 키워드를 숨겨진 input과 화면에 표시 -->
							                                <input type="text" name="kwrdNm" value="${keyword}" style="display:none ;"/>
							                                <span class="kwrdNm">${keyword}</span>
							                                <button type="button" class="deleteKeyword">x</button>
							                            </div>
							                        </c:forEach>
							                    </c:forEach>
							                </c:if>
							            </div>
							        </div>
							    </div>
							</div>
							<!-- 개발 서비스 타입 끝  -->
						</div>
					</div>
				</div>
				<!-- 기본정보 끝 -->
				<!-- 가격정보 -->
				<div>
					<div class="GigFormInput2">
						<div class="GigFormInput_title">
							<p>가격정보 수정</p>
						</div>
						<div class="FormInput2">
							<div class="form-group5">
								<div class="form-sub-group2_1">
									<div class="category2_1">
										<label class="label2_1">금액(VAT포함)<span class="required">*</span></label> 
										<input type="number" id="outordAmt" name="outordAmt"
       											class="title_2" 
       											value="${outsouVO.outordAmt}" required/>
									</div>
									<div class="category2_2">
										<div>
										<label class="label2_1">금액 설명<span class="required">*</span></label> 
										</div>
										<textarea  id="outordAmtExpln" name="outordAmtExpln" 
										class="title_3"   wrap="hard" required>${outsouVO.outordAmtExpln}</textarea>
									</div>
									<div class="category2_3">
										<label class="label2_1">작업 기간</label> 
										<select id="osDevalVO.srvcJobpd"
												name="osDevalVO.srvcJobpd" class="title_2" >
											<option value=""  disabled>선택해주세요</option>
											<c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRJP').codeVOList}">
												<option value="${CodeVO.comCode}" 
											            <c:if test="${CodeVO.comCode == osDevalVO.srvcJobpd}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
											</c:forEach>
										</select>
									</div>
									<div class="category2_3">
										<label class="label2_1">수정 횟수</label> 
										<select id="osDevalVO.srvcUpdtnmtm"
											name="osDevalVO.srvcUpdtnmtm" class="title_2" >
											<option value=""  disabled>선택해주세요</option>
											<c:forEach var="CodeVO" items="${codeGrpVOMap.get('SRUM').codeVOList}">
												<option value="${CodeVO.comCode}" 
											            <c:if test="${CodeVO.comCode == osDevalVO.srvcUpdtnmtm}">
											                selected
											            </c:if>
											        >${CodeVO.comCodeNm}</option>
											</c:forEach>
										</select>
									</div>
									<div class="category2_4">
										<label class="label2_1">수정가능 파일 제공</label>
										<p>의뢰인에게 소스파일을 제공할 경우 체크해주세요</p>
										<!--   체크박스가 해제될 경우 기본값으로 '0'을 보내기 위해 hidden input 사용 -->
									    <input type="hidden" name="osDevalVO.srvcFileprovdyn" value="0" />
									    
									    <input type="checkbox" class="title_4" 
									           id="osDevalVO.srvcFileprovdyn" 
									           name="osDevalVO.srvcFileprovdyn" value="1"
									           <c:if test="${outsouVO.osDevalVO.srvcFileprovdyn == '1'}">checked</c:if> />
									</div>
									<div class="category2_3">
										<label class="label2_1">기능 추가</label> 
										<input type="text"  
												id="osDevalVO.srvcSklladit" name="osDevalVO.srvcSklladit"
											class="title_2" value="${outsouVO.osDevalVO.srvcSklladit}" />
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<!--  가격 정보 끝 -->
				<!--  서비스 설명 -->
				<div class="GigFormInput3">
					<div>
						<div class="GigFormInput_title">
							<p>서비스 설명</p>
						</div>
						<div class="form-group6">
							<label for="outordExpln"></label>
							<div id="perDetTemp1">${outsouVO.outordExpln}</div>
							<textarea rows="3" cols="30" class="form-control" name="outordExpln"
								id="outordExpln" style="display: none;" >${outsouVO.outordExpln}</textarea>
						</div>
						<div class="GigFormInput_title">
							<p>서비스 제공절차</p>
						</div>
						<div class="form-group6">
							<label for="outordProvdprocss"></label>
							<div id="perDetTemp2">${outsouVO.outordProvdprocss}</div>
							<textarea rows="3" cols="30" class="form-control" name="outordProvdprocss"
								id="outordProvdprocss"style="display: none;" >${outsouVO.outordProvdprocss}</textarea>
						</div>
						<div class="GigFormInput_title">
							<p>환불규정</p>
						</div>
						<div class="form-group6">
							<label for="outordRefndregltn"></label>
							<div id="perDetTemp3">${outsouVO.outordRefndregltn}</div>
							<textarea rows="3" cols="30" class="form-control" name="outordRefndregltn"
								id="outordRefndregltn" style="display: none;">${outsouVO.outordProvdprocss}</textarea>
						</div>
						
						
					</div>
				</div>
				<!--  서비스 설명  끝-->
				<input type="hidden" />
				<!--  이미지 등록 시작  -->
				<div class="GigFormInput4">
						<!-- 메인 이미지 등록 -->
						<div class="GigFormInput_title">
							<p>이미지 파일</p>
						</div>
						<div class="mainimg">
							<div class="form-group7">
								<div>
									<p>메인 이미지 등록<span class="required">*</span></p>
								</div>
								<div class="category4">
					                <!-- 이미지 클릭 시 파일 업로드 -->
					                <div class="imgupload">
					                    <label for="mainFile"> 
					                        <img id="mainImagePreview" src="../resources/images/이미지 등록.png" alt="메인 이미지">
					                    </label>
					                </div>
					                <!-- 
					                required : 기존에 이미 메인 이미지가 있어도 꼭 다시 업로드를 해야 하는 상황
					                 -->
					                <input type="file" id="mainFile" name="mainFile" class="real-upload" accept="image/*" />
					            </div>
							</div>
							<div class="form-group7">
								<div id="mainpImg">
									<img src="${outsouVO.outordMainFile}"
										alt="${outsouVO.outordMainFile}" class="product-image" id="pImg" />
								</div>
							</div>
						</div>
					<div class="detailImg">
						<!-- 상세 이미지 등록 -->
						<div class="form-group7">
							<div>
								<p>상세 이미지 등록(선택)</p>
							</div>
							<div class="form-sub-group7">
								<div class="category4">
				                <!-- 이미지 클릭 시 파일 업로드 -->
				                <div class="imgupload">
				                    <label for="detailFile"> 
				                        <img id="mainImagePreview" src="../resources/images/이미지 등록.png" alt="메인 이미지">
				                    </label>
				                </div>
				                <input type="file" id="detailFile" name="detailFile" class="real-upload" accept="image/*" multiple/>
           					 </div>
							</div>
						</div>
							<div class="form-group7">
								<div id="detpImg">
									 <c:if test="${fileDetail.filePathNm != '1'}">
									<c:forEach var="fileDetail" items="${outsouVO.fileDetailVOList}">
										<img src="${fileDetail.filePathNm}" alt="Detail Image"
											class="product-image" id="pImg" />
									</c:forEach>
									</c:if>
									</div>
							</div>
					</div>
				</div>
				<!--  이미지 등록 끝  -->
				<!-- 요청사항 -->
				<div class="GigFormInput5">
					<div>
						<div class="GigFormInput_title">
							<p>작업 전 요청사항</p>
						</div>
						<div class="form-group8">
							<label for="outordDmndmatter"></label>
							<div id="perDetTemp4">${outsouVO.outordDmndmatter}</div>
							<textarea rows="3" cols="30" class="form-control" name="outordDmndmatter"
								id="outordDmndmatter" style="display: none;" >${outsouVO.outordDmndmatter}</textarea>
						</div>
					</div>
					<div id="editBox">
						<p>
							<input type="button" class="cancel" value="취소" /> 
							<input type="submit" id="savebtn" value="수정" />
						</p>
					</div>
				</div>
				<!-- 요청사항  끝 -->
				<sec:csrfInput />
			</form>
		</div>
	</div>
</div>
<!-- 서비스 설명 부분에 해당하는 스크립트 -->
<script type="text/javascript">
// CKEditor 인스턴스를 저장할 객체
let editors = {}; // 각 CKEditor 인스턴스를 저장하기 위한 객체 생성

// 서비스 설명 CKEditor5 적용
ClassicEditor.create(document.querySelector('#perDetTemp1'), {ckfinder: { uploadUrl: '/image/upload?${_csrf.parameterName}=${_csrf.token}' }}) //// CKFinder로 파일 업로드 기능 추가
.then(editor => {editors['perDetTemp1'] = editor; // 'perDetTemp1'에 해당하는 CKEditor 인스턴스를 editors 객체에 저장

    // CKEditor의 데이터 변경 시 실행
    editor.model.document.on('change:data', () => {
        $('#outordExpln').val(editor.getData()); // 서비스 설명 데이터를 텍스트 영역에 저장
    });
})
.catch(err => { console.error(err.stack); }); // 에디터 생성 중 오류 발생 시 콘솔에 오류 출력

// 서비스 제공 절차 CKEditor5 적용
ClassicEditor.create(document.querySelector('#perDetTemp2'), {ckfinder: { uploadUrl: '/image/upload?${_csrf.parameterName}=${_csrf.token}' }})
.then(editor => {editors['perDetTemp2'] = editor; // 'perDetTemp2'에 해당하는 CKEditor 인스턴스를 editors 객체에 저장

    // CKEditor의 데이터 변경 시 실행
    editor.model.document.on('change:data', () => {
        $('#outordProvdprocss').val(editor.getData());
    });
})
.catch(err => { console.error(err.stack); });

// 환불 규정 CKEditor5 적용
ClassicEditor.create(document.querySelector('#perDetTemp3'), {ckfinder: { uploadUrl: '/image/upload?${_csrf.parameterName}=${_csrf.token}' }})
.then(editor => {editors['perDetTemp3'] = editor;

    // CKEditor의 데이터 변경 시 실행
    editor.model.document.on('change:data', () => {
        $('#outordRefndregltn').val(editor.getData());
    });
})
.catch(err => { console.error(err.stack); });

// 요청 사항 CKEditor5 적용
ClassicEditor.create(document.querySelector('#perDetTemp4'), {ckfinder: { uploadUrl: '/image/upload?${_csrf.parameterName}=${_csrf.token}' }})
.then(editor => {editors['perDetTemp4'] = editor; 

    // CKEditor의 데이터 변경 시 실행
    editor.model.document.on('change:data', () => {
        $('#outordDmndmatter').val(editor.getData());
    });
})
.catch(err => { console.error(err.stack); });
</script>
