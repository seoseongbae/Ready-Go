<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="sec"
	uri="http://www.springframework.org/security/tags"%>
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script>
<!-- css 파일 -->
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/resources/css/board/List.css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/alert.css" />

<sec:authentication property="principal" var="prc" />
<style>
#wait{
	color: #666363;
	width : 80px;
	background-color: rgb(244 244 244);
    font-weight: 450;
    border: none;
    border-radius: 999px;
    margin-left: 65px;
}
#complete{
	color: #24D59E;
	width : 80px;
    background-color: #e8faf8;
    font-weight: 450;
    border: none;
    border-radius: 999px;
    margin-left: 65px;
}
#admNotice{
	color: white;
	width : 80px;
	background-color: #24D59E;
    font-weight: 450;
    border: none;
    border-radius: 999px;
    margin-left: 65px;
}
</style>
<script type="text/javascript">
$(document).ready(function() {
    $('.ListTitle').on('click', function(event) {
        // 게시글 속성 가져오기
        var pstOthbcscope = $(this).data('pst-othbcscope'); // 공개설정 정보
        var mbrId = $(this).data('mbr-id'); // 작성자 ID

        // 로그인된 사용자 이름을 서버에서 가져와 자바스크립트 변수로 저장
        var prcUsername = '${prc != "anonymousUser" ? prc.username : "anonymousUser"}';

        // 1. 비로그인 사용자일 경우
        if (prcUsername === 'anonymousUser' && pstOthbcscope === '비공개') {
            event.preventDefault(); // 링크 이동 중단
            Swal.fire({
                title: '비공개 게시글입니다.',
                text: "작성자는 로그인 후 이용 해주세요",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: 'white',
                cancelButtonColor: 'white',
                confirmButtonText: '예',
                cancelButtonText: '아니오',
                
                
              }).then((result) => {
                if (result.isConfirmed) {
                  window.location.href = "/security/login"
                }
              })
            return;
        }

        // 2. 비공개 설정이고, 로그인한 사용자와 작성자가 다르면 경고창 띄우고 링크 이동 중단
        if (pstOthbcscope === '비공개' && prcUsername !== mbrId) {
            event.preventDefault(); // 링크 이동 중단
            Swal.fire({
                icon: 'info',
                title: '비공개 게시글입니다.',
              });
            return;
        }
    });

    $('.boardRegist').on('click', function(event) {
        var prcUsername = '${prc != "anonymousUser" ? prc.username : "anonymousUser"}';

        if (prcUsername === "anonymousUser") {
            event.preventDefault(); // 기본 폼 제출 막기
            Swal.fire({
                title: '로그인 후 작성 할 수 있습니다.',
                text: "로그인 페이지로 이동하시겠습니까?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: 'white',
                cancelButtonColor: 'white',
                confirmButtonText: '예',
                cancelButtonText: '아니오',
                
                
              }).then((result) => {
                if (result.isConfirmed) {
                  window.location.href = "/security/login"
                }
              })
            return;
        } else {
            window.location.href = '/common/inquiryBoard/inquiryRegist';
        }
    });
})

</script>

<div class="inquiryRow">
	<div class="registTitle">
		<h2>문의 게시판</h2>
	</div>
	<div class="sortingALl">
		<div class="count">
			<p id="count">
				전체&nbsp;&nbsp;<span id="total">${articlePage.total}</span>
			</p>
			<br>
		</div>
	</div>
	<div class="card_body table_responsive p_0">
			<table>
			<thead >
				<tr style="background:#f3f3f3; border-top: 2px solid #232323;">
					<th class="number" style="width: 20%;">상태</th>
					<th class="contTitle" style="width: 40%;">제목</th>
					<th class="Public" style="width: 10%;">공개설정</th>
					<th class="write" style="width: 15%;">작성자</th>
					<th class="write" style="width: 15%;">작성일</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="boardVO" items="${articlePage.content}">
				    <tr style="<c:if test="${boardVO.mbrId =='admin'}">background-color:  #F0FCF8;</c:if>">
				        <td>
				            <c:if test="${boardVO.mbrId == 'admin'}"><p id="admNotice">${boardVO.pstOthbcscope}</p></c:if>
				            <c:if test="${boardVO.mbrId != 'admin'}">
				                <c:choose>
				                    <c:when test="${boardVO.replyCnt gt 0}">
				                        <p id="complete">답변완료</p>
				                    </c:when>
				                    <c:otherwise>
				                        <p id="wait">답변대기</p>
				                    </c:otherwise>
				                </c:choose>
				            </c:if>
				        </td>
				        <td class="contTitle">
				            <a class="ListTitle"
				                href="/common/inquiryBoard/inquiryDetail?seNo=4&pstSn=${boardVO.pstSn}"
				                data-pst-othbcscope="${boardVO.pstOthbcscope}"
				                data-mbr-id="${boardVO.mbrId}">${boardVO.pstTtl}</a>
				        </td>
				        <td>
				            <c:if test="${boardVO.mbrId != 'admin'}">${boardVO.pstOthbcscope}</c:if>
				        </td>
				        <c:choose>
				            <c:when test="${boardVO.mbrId == 'admin'}">
				                <td>★관리자</td>
				            </c:when>
				            <c:otherwise>
				                <td>${boardVO.mbrId}</td>
				            </c:otherwise>
				        </c:choose>
				        <td>${boardVO.pstWrtDt}</td>
				    </tr>
				</c:forEach>
              </tbody> 
              <tfoot>
					<tr></tr>
				</tfoot>              
		</table>        
		<div class="button-container">
			<button type="button" class="btn btn-default boardRegist">등록</button>
		</div>
		
		<!-- Pagination -->
		<div class="card-body table-responsive p-0" style="display: flex; justify-content: center;">
		    <table style="margin-bottom: 30px;">
		        <tr>
		            <td colspan="4" style="text-align: center;">
		                <div class="dataTables_paginate" id="example2_paginate" style="display: flex; justify-content: center; margin-top: 20px;">
		                    <ul class="pagination">
		
		                        <!-- 맨 처음 페이지로 이동 버튼 -->
		                        <c:if test="${articlePage.currentPage gt 1}">
		                            <li class="paginate_button page-item first"><a
		                                href="/common/inquiryBoard/inquiryList?currentPage=1"
		                                aria-controls="example2" data-dt-idx="0" tabindex="0" class="page-link">&lt;&lt;</a></li>
		                        </c:if>
		
		                        <!-- 이전 페이지 버튼 -->
		                        <c:if test="${articlePage.startPage gt 5}">
		                            <li class="paginate_button page-item previous" id="example2_previous">
		                                <a href="/common/inquiryBoard/inquiryList?currentPage=${(articlePage.currentPage - 5) lt 1 ? 1 : (articlePage.startPage - 1)}"
		                                   aria-controls="example2" data-dt-idx="0" tabindex="0" class="page-link">&lt;</a></li>
		                        </c:if>
		
		                        <!-- 페이지 번호 -->
		                        <c:forEach var="pNo" begin="${articlePage.startPage}" end="${articlePage.endPage}">
		                            <li class="paginate_button page-item ${pNo == articlePage.currentPage ? 'active' : ''}">
		                                <a href="/common/inquiryBoard/inquiryList?currentPage=${pNo}" aria-controls="example2" class="page-link">${pNo}</a>
		                            </li>
		                        </c:forEach>
		
		                        <!-- 다음 페이지 버튼 -->
		                        <c:if test="${articlePage.endPage lt articlePage.totalPages}">
		                            <li class="paginate_button page-item next" id="example2_next">
		                                <a href="/common/inquiryBoard/inquiryList?currentPage=${articlePage.currentPage + 5}"
		                                   aria-controls="example2" data-dt-idx="7" tabindex="0" class="page-link">&gt;</a></li>
		                        </c:if>
		
		                        <!-- 맨 마지막 페이지로 이동 버튼 -->
		                        <c:if test="${articlePage.currentPage lt articlePage.totalPages}">
		                            <li class="paginate_button page-item last">
		                                <a href="/common/inquiryBoard/inquiryList?currentPage=${articlePage.totalPages}"
                                   aria-controls="example2" data-dt-idx="7" tabindex="0" class="page-link">&gt;&gt;</a></li>
                        </c:if>

                    </ul>
                </div>
            </td>
        </tr>
    </table>
</div>

		
		
		
	</div>
</div>