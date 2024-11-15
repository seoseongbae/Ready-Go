<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="sec"
	uri="http://www.springframework.org/security/tags"%>
<script type="text/javascript" src="/resources/ckeditor5/ckeditor.js"></script>
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<!-- css 파일 -->
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/resources/css/board/Detail.css" />

<script type="text/javascript">
$(function(){
    // CKEditor 글 복제
    $(".ck-blurred").keydown(function(){
        $("#pstCn").val(window.editor.getData());
    });

    $("#uploadFile").on("change", handleImg);

    $(".ck-blurred").focusout(function(){
        $("#perDet").val(window.editor.getData());
    });

});
ClassicEditor.create(document.querySelector('#pstCnTemp'))
.then(editor => {
    editor.enableReadOnlyMode('#pstCnTemp');
    window.editor = editor;
    
    // 폼 제출 전 CKEditor의 내용을 textarea에 동기화
    document.querySelector('#registForm').addEventListener('submit', function(event) {
        document.querySelector('#pstCn').value = editor.getData();
    });
})
.catch(error => {
    console.error(error);
});

</script>

<div class="container2">
	
	<div class="registTitle">
		<h2>공지 게시글</h2>
	</div>
	<div class="title-group">
		<div class="content-group">
			<form name="deletePost" id="deletePost"
				action="/adm/notice/deletePost" method="post">
				<div class="Content">
					<div class="rv-detail">
						<!--  제목 -->
						<div class="titlegroup">
							<div class="left" >
			                     <p style="font-weight: bold;  font-size: 30px;"> [${boardVO.pstOthbcscope}]&nbsp;${boardVO.pstTtl}</p>
		                  	</div>
						</div>
						<!--  제목 -->
						<!-- 작성자, 작성일, 조회수 -->
						<div class="reviewWit">
							<c:if test="${boardVO.pstMdfcnDt != null}">
								<div class="wit">
									<p>작성자 : ★관리자
									<p>
									<p>작성일&nbsp;:&nbsp;${boardVO.pstMdfcnDt}&nbsp;(수정됨)</p>
								</div>
							</c:if>
							<c:if test="${boardVO.pstMdfcnDt == null}">
								<div class="wit">
									<p>작성자 : ★관리자
									<p>
									<p>작성일&nbsp;:&nbsp;${boardVO.pstWrtDt}</p>
								</div>
							</c:if>
							<div class="upDown">
								<p>조회수&nbsp;:&nbsp;${boardVO.pstInqCnt}</p>
							</div>
						</div>
						<!-- 작성자, 작성일, 조회수 -->
						<!-- 첨부 파일 다운로드 링크 -->
						<c:forEach var="file" items="${fileDetails}">
						<div class="filelist">
							<a href="/download?fileName=${file.filePathNm}" download="${file.orgnlFileNm}">
								<i class="fas fa-link mr-1" style="font-weight: 600; font-size: 14px;">${file.orgnlFileNm}
									(${file.fileFancysize})</i>
							</a>
						</div>
						</c:forEach>
						<!-- 첨부 파일 다운로드 링크 -->
					<div class="hr"></div>
					<!-- 리뷰내용 -->
					<div class="pstCn">${boardVO.pstCn}</div>
				</div>
				</div>
				<!-- 버튼 배치 -->
				<div class="button-container">
					<!-- 공지 목록 버튼 (왼쪽 정렬) -->
		            	<div id="editBox1">
							<button type="button" id="savebtn"  class="btn btn-List" onclick="location.href='/common/notice/noticeList'">목록</button>
						</div>
					<div class="button-group-right">
						<input type="hidden" id="pstSn" name="pstSn" value="${boardVO.pstSn}" />
					</div>
				</div>
				<sec:csrfInput />
			</form>
		</div>
	</div>
</div>
	<script type="text/javascript">

ClassicEditor.create(document.querySelector('#pstCnTemp'))
    .then(editor => {
        editor.enableReadOnlyMode('#pstCnTemp');
        window.editor = editor;
        
        // 폼 제출 전 CKEditor의 내용을 textarea에 동기화
        document.querySelector('#registForm').addEventListener('submit', function(event) {
            document.querySelector('#pstCn').value = editor.getData();
        });
    })
    .catch(error => {
        console.error(error);
    });
</script>