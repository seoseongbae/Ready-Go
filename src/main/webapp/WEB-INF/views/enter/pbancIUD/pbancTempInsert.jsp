<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="sec"
	uri="http://www.springframework.org/security/tags"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script type="text/javascript" 
	src="//dapi.kakao.com/v2/maps/sdk.js?appkey=eaad16168d2cb5b733bf76e1a41ced77&libraries=services"></script>
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/resources/css/enter/pbancInsert.css" />
	   <link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/alert.css" />
   <script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script>
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<script type="text/javascript" src="/resources/ckeditor5/ckeditor.js"></script>
<script type="text/javascript"
	src="/resources/ckeditor5/sample/css/sample.css"></script>
<style type="text/css">
.ddalkkack{
	font-size: 6px;
	width: 25px;
	height: 25px;
	border: 1px solid #24D59E;
	border-radius: 100%;
	background-color: #ffffff;
	color: #24D59E;
	margin-bottom: 10px;
}
</style>
</head>
<div style="position:fixed;bottom: 0; right: 0; display: flex; flex-direction: column; padding: 20px;">
<button class="ddalkkack" id="mg">딸깍</button>
</div>
<body>
	<sec:authentication property="principal" var="prc" />
	<c:if test="${prc ne 'anonymousUser'}">
		<input type="hidden" id="hasRoleEnter" value="${prc.authorities}" />
	</c:if>
	<c:if test="${prc  ne 'anonymousUser'}">
			<h2>공고 등록</h2>
			<div class="background">
				<!-- 담 당자 정보 -->
				<section class="section">
					<h4>기업 정보</h4>
					<h5>먼저 기업 정보가 맞는지 확인해주세요</h5>
						<div class="flexPbanc"> 
							<div>
								<div class="form-group">
									<label for="entRprsntvNm"><b>*</b> 대표자 성함</label> 
									<p class="enterInfo">${enterVO.entRprsntvNm}</p>
								</div>
								<div class="form-group">
									<label for="tpbizCd"><b>*</b> 업종</label> 
									<p class="enterInfo">${enterVO.tpbizSeCd}</p>
								</div>								
								<div class="form-group">
									<label for="location"><b>*</b> 대표 근무지역</label> 
									<p class="enterInfo">(${enterVO.entZip}) ${location.entAddr}, ${location.entAddrDetail}</p>
								</div>
								<div id="staticMap" class="map" style="width: 960px; height: 300px;"></div>
							</div>	
							
							
							<div style="margin-left: -380px;">
								<div class="form-group multi-input">
									<label for="entFxnum"><b>*</b> 팩스번호</label> 
									<p class="enterInfo">${enterVO.entFxnum}</p>
								</div>
								<div class="form-group">
									<label for="entMail"><b>*</b> 이메일 주소</label> 
									<p class="enterInfo">${enterVO.entMail}</p>
								</div>
							</div>	
						</div>	
							<div class="sec1-btn">
								<a href="/enter/edit?entId=${prc.username}">
							    	<button type="button" class="modalOk" id="up-btn">수정</button>
							    </a>
							    <button type="button" class="modalGo">확인</button>
							</div>						
							<p class="sec1-p">기업 정보 수정 필요 시 '수정', 기업 정보가 모두 일치 시 '확인' 버튼을 클릭해주세요.</p>
				</section>
				
				<!-- //////////////////////////////////여기부터 form 태그 시작////////////////////////////////// -->								
				
				<form name="pbancInsert" id="pbancInsert" method="post" 
					  action="/enter/pbancTempInsertPost?${_csrf.parameterName}=${_csrf.token}" 
					  enctype="multipart/form-data">	
				<input type="hidden" value="${pbancDetailList.pbancNo}" name="pbancNo"/>  			
				<!-- /////////////////////모집 정보///////////////////// -->
			
				<section class="section" hidden="hidden">
					<input type="hidden" id="entId"name="entId" value="${enterVO.entId}" />
					<h4>모집 분야</h4>
					<h5>어떤일을 담당할 직원을 찾으시나요?</h5>
					<div class="flexPbanc">
						<div>
							<div class="form-group">
								<label for="jobType"><b>*</b> 모집분야명</label> 
								<c:if test="${pbancDetailList.rcritNm ne null}">
									<input type="text" id="jobType" name="rcritNm" value="${pbancDetailList.rcritNm}" required>
								</c:if>
								<c:if test="${pbancDetailList.rcritNm eq null}">
									<input type="text" id="jobType" name="rcritNm" value="" placeholder="예: 앱개발자"required>
								</c:if>
								<c:if test="${pbancDetailList.rcritCnt ne null}">								
									<input type="number" id="applicants" value="${pbancDetailList.rcritCnt}" name="rcritCnt" min="0"placeholder="0" required> 
								</c:if>
								<c:if test="${pbancDetailList.rcritCnt eq null}">
									<input type="number" id="applicants" value="" name="rcritCnt" min="0"placeholder="0" required> 								
								</c:if>
								<label for="applicants">명 모집</label>
							</div>
							<div class="form-group radio-group">
								<label for="pbancCareerCd"><b>*</b> 경력여부</label>
								<div>
								<select class="input-detail" id="careeee" name="pbancCareerCd" required>
									<option value="" disabled>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getRecruitmentCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancCareerCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>
								</div>
							</div>
							<div class="form-group">
								<label for="rcritJbttlCd"><b>*</b> 직급/직책</label> 
								<select class="input-detail" id="jbtttt" name="rcritJbttlCd" required>
									<option value="" disabled>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getRcritJbttlCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.rcritJbttlCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>	
							</div>							
						</div>
						<div>
							<div class="form-group">
								<label for="rcritDept" class="noneStar">근무부서</label>
								<c:if test="${pbancDetailList.rcritDept ne null}">
									<input type="text" id="work" name="rcritDept" value="${pbancDetailList.rcritDept}">
								</c:if>
								<c:if test="${pbancDetailList.rcritDept eq null}">
									<input type="text" id="work" name="rcritDept" placeholder="예: 개발팀"value="">
								</c:if>
							</div>
							<div class="form-group">
								<label for="rcritTask" class="noneStar">담당업무</label>
								<c:if test="${pbancDetailList.rcritTask ne null}">
									<input type="text" id="task" name="rcritTask" value="${pbancDetailList.rcritTask}">
								</c:if> 
								<c:if test="${pbancDetailList.rcritTask eq null}">
									<input type="text" id="task" name="rcritTask"placeholder="예: 앱 개발 및 유지보수" value="">
								</c:if> 
							</div>
							<div class="form-group">
								<label for="tpbizCd"><b>*</b> 모집업종</label> 
								<select class="input-detail" id="tpbizCd" name="tpbizCdList" multiple required>
									<option value="" disabled>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getTpbizCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
										<c:forEach var="tpbizCd" items="${tpbizCdList}">
											<c:if test="${pbancVO.comCodeNm eq tpbizCd}">selected</c:if>
										</c:forEach>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>								
							</div>		
							   <div id="selectedOptionsDiv"></div>					
						</div>
					</div>
					<h6>
						<b class="bb">추가</b>를 클릭하면 필수/우대 조건을 추가할 수 있습니다.
					</h6>
					<div class="flexPbanc">
						<div>
							<div class="form-group" id="ll">
								<label for="pvLtCn"><b>*</b> 필수 조건</label> 
								<input type="text" id="requiredCn" placeholder="예: 해당 직무 근무 경험"d>
								<button type="button" class="add-btn1">추가</button>
							</div>
							<div class="column3">
								<c:if test="${requiredList ne null}">
									<c:forEach var="requiredCn" items="${requiredList}">
										<div class="required-input-del">
										<input type="text" value="${requiredCn}" id="required-foreach" name="requiredCnList" class="input-detail" required/>
										<button class="delBtn4"><img class="delImg" src="../resources/icon/delete.png"></button>
										</div>
									</c:forEach>
								</c:if>
							</div>
							<div id="hiddenRequiredList"></div>
							<div id="dynamicList1"></div>
						</div>
						<div>
							<div class="form-group" id="rr">
								<label for="pvLtCn" class="noneStar">우대 조건</label> 
								<input type="text" id="preferCn" placeholder="예: 정보처리기사 자격증 ">
								<button type="button" class="add-btn2">추가</button>
							</div>
							<div class="column4">
								<c:if test="${preferList ne null}">
									<c:forEach var="preferCn" items="${preferList}">
										<div class="prefer-input-del">
										<input type="text" value="${preferCn}" id="prefer-foreach" name="preferCnList" class="input-detail"/>
										<button class="delBtn5"><img class="delImg" src="../resources/icon/delete.png"></button>
										</div>
									</c:forEach>
								</c:if>
							</div>
							<div id="hiddenPreferList"></div>
							<div id="dynamicList2"></div>
						</div>
					</div>	
					<h6>
						<b class="bb">추가</b>를 클릭하면 복지 및 혜택을 추가할 수 있습니다.
					</h6>
					<div class="flexPbanc">
						<div>
							<div class="form-group" id="ll">
								<label for="pvLtCn" class="noneStar">복지 및 혜택</label> 
								<input type="text" id="favor" name="pvLtCn" placeholder="예: 점심시간 3시간">
								<button type="button" class="add-btn3">추가</button>
							</div>
							
							<div class="column1">
							<c:if test="${favorList ne null}">
								<c:forEach var="favorCn" items="${favorList}">
									<div class="favor-input-del">
									<input type="text" value="${favorCn}" id="favor-foreach" name="favorList" class="input-detail"/>
									<button class="delBtn1"><img class="delImg" src="../resources/icon/delete.png"></button>
									</div>
								</c:forEach>
							</c:if>
							</div>
							<div id="dynamicList3"></div> 
							<div id="hiddenFavorList"></div>
						</div>
					</div>	
				</section>

				<!-- /////////////////////자격/조건///////////////////// -->
				<section class="section" hidden="hidden">
					<h4>자격/조건</h4>
					<h5>어떤일을 담당할 직원을 찾으시나요?</h5>
					<div class="flexPbanc">
						<div>
							<div class="form-group">
								<label for="pbancAplctEduCd"><b>*</b> 지원자 학력</label> 
								<select id="education" name="pbancAplctEduCd" required>
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getPbancEduCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancAplctEduCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>									
							</div>
							<div class="form-group">
								<label for="pbancSalary"><b>*</b> 연봉/급여</label> 
								<select id="salary-type">
									<option value="연봉">연봉</option>
									<option value="월급">월급</option>
								</select> 
								<select class="input-detail" id="salary-money" name="pbancSalary" required>
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getPbancSalaryCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancSalaryNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>									
								<input type="text" id="additional-salary"
									name="additional-salary" placeholder="기타 급여사항">
							</div>
							<p class="sal-standard">
								최저시급 9,860원, 주 40시간 기준 최저연봉 2,060,740원 <a class="sal-line">최저임금제도
									안내</a><br> 최저임금을 준수하지 않는 경우, 공고 강제 마감 및 행정처분을 받을 수 있습니다.
							</p>
						</div>
						
						<!-- 최저임금제도 안내 모달 -->
						<div id="salaryModal" class="modal">
						  <div class="modal-content">
						    <div class="flexPbancc">
						      <h2 id="salModal">최저임금제도 안내</h2>
						      <span class="close">&times;</span>
						    </div>
						    <div class="image-container">
						      <img src="../resources/images/enter/최저임금제도.jpg" alt="최저임금제도 이미지" style="width:100%">
						    </div>
						    
						    <p class="salModalCn">
						      <strong id="cnTitle">최저임금제도 목적</strong> 
						      <button id="accordion-btn" class="accordion">보기</button>
						    </p>
						    <!-- 아코디언 내용 -->
						    <br>
						    <div id="accordion-content" class="accordion-content">
						      <p>최저임금제도는 근로자에 대하여 임금의 최저수준을 보장하여 근로자의 생활안정과 노동력의 질적 향상을 꾀함으로써 
						               국민경제의 건전한 발전에 이바지하게 함을 목적으로 함.(최저임금법 제1조)</p>
						      <p>최저임금제도의 실시로 최저임금액 미만의 임금을 받고 있는 근로자의 임금이 최저임금액 이상 수준으로 인상되면서 다음과 같은 효과를 가져옴.</p>
						      <ul>
						        <li>1. 저임금 해소로 임금격차가 완화되고 소득분배 개선에 기여</li>
						        <li>2. 근로자에게 일정한 수준 이상의 생계를 보장해 줌으로써 근로자의 생활을 안정시키고 근로자의 사기를 올려주어 노동생산성이 향상</li>
						        <li>3. 저임금을 바탕으로 한 경쟁방식을 지양하고 적정한 임금을 지급토록 하여 공정한 경쟁을 촉진하고 경영합리화를 기함.</li>
						      </ul>
						    </div>
							<div class="modalBtn">
							    <button type="button" class="modalOk">확인</button>
							    	<a href="https://www.minimumwage.go.kr/minWage/policy/decisionMain.do" target="_blank">
							    <button type="button" class="modalGo">최저임금위원회</button>
							    </a>
							</div>
						  </div>
						</div>
						
						<div style="margin-left: 80px;">
							<div class="form-group">
								<label for="pbancGenCd">지원자 성별</label> 
								<select class="input-detail" id="gender" name="pbancGenCd">
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getPbancGenCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancGenCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>								
							</div>
							<div class="form-group">
								<label for="pbancAgeCd">지원자 연령</label> 
								<select class="input-detail" id="age" name="pbancAgeCd">
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getPbancAgeCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancAgeCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>									
							</div>
						</div>
					</div>	
					<div class="flexPbanc">
						<div>
							<div class="form-group">
								<label for="pbancWorkstleCd"><b>*</b> 근무형태</label>
								<div class="checkbox-group">
									<select class="input-detail" id="workstle" name="pbancWorkstleCd" required>
										<option value="" disabled selected>선택해주세요</option>
										<c:forEach var="pbancVO" items="${getPbancWorkstleCD}" varStatus="status">
											<option value="${pbancVO.comCode}"
												<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancWorkstleCdNm}">selected</c:if>
											>${pbancVO.comCodeNm}</option>
										</c:forEach>
									</select>										
								</div>
							</div>
							<div class="form-group">
								<label for="powkCd"><b>*</b> 근무지역</label>
								<div class="powkCd">
								<select class="input-detail" id="powkCd" name="powkList" multiple required>
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${powkCdList}" varStatus="status">
										<option value="${pbancVO.comCode}"
										<c:forEach var="powkCd" items="${powkList}">
											<c:if test="${pbancVO.comCodeNm eq powkCd}">selected</c:if>
										</c:forEach>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>									
								</div>
							</div>
						</div>
						<div  style="margin-left: 355px;">
							<div class="form-group">
								<label for="pbancWorkDayCd">근무요일</label>
								<select class="input-detail" id="workday" name="pbancWorkDayCd">
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getPbancWorkDayCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancWorkDayCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>								
							</div>
							<div class="form-group">
								<label for="pbancWorkHrCd">근무시간</label> 
								<select class="input-detail" id="worktime" name="pbancWorkHrCd">
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getPbancWorkHrCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancWorkHrCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>									
							</div>
						</div>
					</div>
				</section>

				<!-- /////////////////////채용절차///////////////////// -->
				<section class="section" hidden="hidden">
					<h4>채용 절차</h4>
					<h5>채용 절차는 어떻게 되나요?</h5>
					<div class="flexPbancc">
						<div>
							<div class="form-group">
								<label for="pbancRprsDty"><b>*</b> 공고 대표 직무</label> 
								<select class="input-detail" id="pbancRprsDty" name="pbancRprsDty" required>
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getTpbizCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancRprsDtyCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>	
							</div>
							<div class="form-group">
								<label for="pbancRcptMthdCd"><b>*</b> 지원 접수 방법</label> 
								<select class="input-detail" id="pbancRcptMthdCd" name="pbancRcptMthdCd" required>
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getPbancRcptMthdCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancRcptMthdCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>	
							</div>
							<div class="form-group">
								<label for="pbancAppofeFormCd"><b>*</b> 지원서 양식</label> 
								<select class="input-detail" id="application-form" name="pbancAppofeFormCd" required>
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getPbancAppofeFormCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.pbancAppofeFormCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>									
							</div>
						</div>
						<div>
							<div class="form-group">
								<label for="period"><b>*</b> 지원 접수 기간</label> 
								<c:if test="${pbancDetailList.pbancBgngDts ne null}">
									<input type="hidden" id="start-date" name="pbancBgngDt" value="${pbancDetailList.pbancBgngDts}">
									<input type="date" id="start-date" name="pbancBgngDts" value="${pbancDetailList.pbancBgngDts}" required>
								</c:if>
								<c:if test="${pbancDetailList.pbancBgngDts eq null}">
									<input type="hidden" id="start-date" name="pbancBgngDt" value="">
									<input type="date" id="start-date" name="pbancBgngDts" value="" required>
								</c:if>
									&nbsp; ~ &nbsp;
								<c:if test="${pbancDetailList.pbancDdlnDts ne null}">
									<input type="hidden" id="end-date" name="pbancDdlnDt" value="${pbancDetailList.pbancDdlnDts}">
									<input type="date" id="end-date" name="pbancDdlnDts"  value="${pbancDetailList.pbancDdlnDts}" required>
								</c:if> 
								<c:if test="${pbancDetailList.pbancDdlnDts eq null}">
									<input type="hidden" id="end-date" name="pbancDdlnDt" value="">
									<input type="date" id="end-date" name="pbancDdlnDts"  value="" required>
								</c:if> 
								
							</div>
							<div class="form-group">
								<label for="procssCd"><b>*</b> 전형절차</label>
								<div class="step-group">
								<select class="input-detail" id="proc" name="procssCd" required>
									<option value="" disabled selected>선택해주세요</option>
									<c:forEach var="pbancVO" items="${getProcssCD}" varStatus="status">
										<option value="${pbancVO.comCode}"
											<c:if test="${pbancVO.comCodeNm eq pbancDetailList.procssCdNm}">selected</c:if>
										>${pbancVO.comCodeNm}</option>
									</c:forEach>
								</select>									
								</div>
							</div>
						</div>
					</div>	
				</section>

				<!-- /////////////////////공고내용///////////////////// -->
				<section class="section" hidden="hidden">
					<h4>공고 내용</h4>
					<h5>공고 내용을 입력해주세요</h5>
                  <div class="form-group">
                     <div style="flex-direction: column;">
	                     <div>
		                     <label for="pbancTtl"><b>*</b> 공고 제목</label> 
		                     <c:if test="${pbancDetailList.pbancTtl ne null}">
		    	                 <input type="text" id="title" name="pbancTtl" value="${pbancDetailList.pbancTtl}" placeholder="제목을 입력하세요" required
		    	                 style="margin-left: -3px;">
		                     </c:if>
		                     <c:if test="${pbancDetailList.pbancTtl eq null}">
		    	                 <input type="text" id="title" name="pbancTtl" value="" placeholder="제목을 입력하세요" required
		    	                 style="margin-left: -3px;">
		                     </c:if>
	                     </div>
	                     <div>
	                     	<div class="error-msg"></div>
	                     </div>
                     </div>
                  </div>
                  <div class="form-group">
					<div style="flex-direction: column;">                     
	                     <div style="display: flex;">
		                     <label for="pbancCn" class="con-pbanc-title"><b>*</b> 공고 내용</label>
		                     <c:if test="${pbancDetailList.pbancCn ne null}">
			                     <div><textarea class="txtara" name="pbancCn" required>${pbancDetailList.pbancCn}</textarea></div>
		                     </c:if>
		                     <c:if test="${pbancDetailList.pbancCn eq null}">
			                     <div><textarea id="cnnnn" class="txtara" name="pbancCn" required></textarea></div>
		                     </c:if>
	                     </div>
	                     <div>
		                     <div class="error-msg"></div>
	                     </div>
                     </div>
                  </div>
					<div class="form-group" id="filegroup">
						<label for="entPbancFile" class="con-pbanc-title"><b>*</b> 공고 파일</label>
						<c:if test="${pbancDetailList.pbancImgFile ne null}">
							<input type="file" id="pbancFile" value="${pbancDetailList.pbancImgFile}" name="entPbancFile" required/>
							<input type="hidden" name="pbancImgFile" value="${pbancDetailList.pbancImgFile}">
						</c:if>
						<c:if test="${pbancDetailList.pbancImgFile eq null}">
							<input type="file" id="pbancFile" value="" name="entPbancFile" required/>
							<input type="hidden" name="pbancImgFile" value="">
						</c:if>
					</div>
						<div class="flexPbanccc">
							<img class="fileImg" src="../resources/icon/warning.png" alt="exclamation"/>
							<p id="pFile">공고 상단에 보일 이미지 파일을 등록해주세요.</p>
						</div>
				</section>
				
				<!-- 버튼 섹션 -->
				<section class="button-section" hidden="hidden">
					<div class="btn-last1">
						<button type="button" class="btn save-btn" id="tempPbancSave">임시 저장</button>
					</div>
					<div class="btn-last2">
						<button type="button" class="btn cancel-btn" onclick="location.href='/enter/tempPbanc?entId=${prc.username}'">취소</button>
						<button type="submit" class="btn submit-btn">공고 등록</button>
					</div>
				</section>
				<sec:csrfInput />
				</form>
			</div>
		</c:if>
</body>

<script>

//-----------------------------------------------필수 조건 추가
$(document).ready(function() {
 let counter = 0; 
 $("#mg").on("click", function(){
	 $("#jobType").val("DBA");
	 $("#applicants").val("1");
	 $("#work").val("유지보수팀");
	 $("#task").val("데이터베이스 설계 및 유지보수");
	 $("#careeee").val("RCCA02").attr("selected", true);
	 $("#jbtttt").val("RCJB08").attr("selected", true);
	 $("#rcritTask").val("데이터베이스 설계및 유지보수");
	 $("#tpbizCd").val("CRDT020").attr("selected", true);
	 $("#requiredCn").val("데이터베이스 업무종사 10년 이상");
	 $("#preferCn").val("데이터베이스 관련 자격증");
	 $("#favor").val("사내 뷔페");
	 $("#education").val("ACSE002").attr("selected", true);
	 $("#gender").val("PBGE03").attr("selected", true);
	 $("#salary-type").val("연봉").attr("selected", true);
	 $("#salary-money").val("PBSA11").attr("selected", true);
	 $("#age").val("PBAG05").attr("selected", true);
	 $("#workstle").val("WOST01").attr("selected", true);
	 $("#workday").val("WODA01").attr("selected", true);
	 $("#powkCd").val("WRGN01").attr("selected", true);
	 $("#worktime").val("WOHR04").attr("selected", true);
	 $("#pbancRprsDty").val("CRDT020").attr("selected", true);
	 $("#start-date").val("2024-10-21");
	 $("#end-date").val("2024-11-03");
	 $("#pbancRcptMthdCd").val("RCMT01").attr("selected", true);
	 $("#proc").val("PRPR02").attr("selected", true);
	 $("#application-form").val("APFO01").attr("selected", true);
	 $("#cnnnn").val("대덕 그룹은 IT 솔루션 개발과 데이터 엔지니어링을 주력으로 하는 선도적인 기업으로, 다양한 산업에 맞춤형 데이터 기반 서비스를 제공하고 있습니다. 현재 우리는 데이터 엔지니어를 채용하여 빅데이터 인프라 구축 및 데이터 파이프라인 설계를 담당할 인재를 찾고 있습니다. 주요 업무는 대규모 데이터를 효율적으로 수집, 저장, 처리하는 시스템을 설계하고, 이를 최적화하는 것입니다.지원자는 Python, Java, SQL 등 데이터 처리에 필요한 프로그래밍 언어에 능숙해야 하며, Hadoop, Spark와 같은 빅데이터 처리 플랫폼 경험이 있는 분을 우대합니다. 또한, 데이터베이스(MySQL, PostgreSQL)와 NoSQL 기술(MongoDB, Cassandra) 사용 경험이 필수적이며, 클라우드 환경(AWS, GCP)에서의 작업 경험이 있으면 좋습니다. 대덕 그룹은 데이터를 기반으로 한 혁신적인 솔루션을 통해 고객의 비즈니스 성장을 도모하며, 이를 가능하게 할 데이터 엔지니어링 전문가들의 역할을 매우 중요하게 생각합니다. 지원자는 문제 해결 능력과 대규모 데이터 시스템에 대한 이해가 깊어야 하며, 새로운 기술 트렌드에 빠르게 적응하고 이를 적용할 수 있는 능력이 요구됩니다. 우리는 경쟁력 있는 연봉과 복리후생을 제공하며, 데이터 중심의 미래를 함께 만들어 갈 인재를 기다리고 있습니다.");
})
 // '추가' 버튼 클릭 이벤트
 $('.add-btn1').click(function() {
     var inputValue = $('#requiredCn').val(); // 입력값 가져오기
     
     // 중복 확인 로직
     var isDuplicate = false;
     $('#dynamicList1 div').each(function() {
         if ($(this).text().includes(inputValue)) {
             isDuplicate = true;
         }
     });

     if (isDuplicate) {
         alert('중복된 조건을 입력할 수 없습니다.');
         return;
     }

     if (inputValue) {
         // 새로운 div 요소 생성
         var newDiv = $('<div></div>').text(inputValue);
         
         // 'x' 버튼 생성
         var removeBtn = $('<button class="delBtn2"><img class="delImg" src="../resources/icon/delete.png"></button>').css({
             marginLeft: '10px',
             cursor: 'pointer'
         });

         // 'x' 버튼 클릭 시 해당 div 삭제와 hidden input 삭제
         removeBtn.click(function() {
             newDiv.remove();
             $('#hiddenRequired' + counter).remove(); // 해당 hidden input도 삭제
         });

         // 입력된 값과 'x' 버튼을 'newDiv'에 추가
         newDiv.append(removeBtn);
         $('#dynamicList1').append(newDiv);

         // Hidden input 생성하여 값 저장
         $('<input>').attr({
             type: 'hidden',
             id: 'hiddenRequired' + counter,
             name: 'requiredCnList', // 서버로 전송될 name
             value: inputValue
         }).appendTo('#hiddenRequiredList');

         counter++; 

         // 입력 필드 초기화
         $('#requiredCn').val('');
     } else {
         alert('필수 조건을 입력하세요.');
     }
 });
});
$(document).ready(function() {
    // 'x' 버튼 클릭 시 해당 input과 div 삭제
    $(document).on('click', '.delBtn4', function() {
        $(this).closest('.required-input-del').remove();
    });
});
//-----------------------------------------------우대 조건 추가
$(document).ready(function() {
 let counter = 0; 
 
 $('.add-btn2').click(function() {
     var inputValue = $('#preferCn').val();
     
     // 중복 확인 로직
     var isDuplicate = false;
     $('#dynamicList2 div').each(function() {
         if ($(this).text().includes(inputValue)) {
             isDuplicate = true;
         }
     });

     if (isDuplicate) {
         alert('중복된 조건을 입력할 수 없습니다.');
         return;
     }

     if (inputValue) {
         var newDiv = $('<div></div>').text(inputValue);
         var removeBtn = $('<button class="delBtn3"><img class="delImg" src="../resources/icon/delete.png"></button>').css({
             marginLeft: '10px',
             cursor: 'pointer'
         });

         removeBtn.click(function() {
             newDiv.remove();
             $('#hiddenPrefer' + counter).remove();
         });

         newDiv.append(removeBtn);
         $('#dynamicList2').append(newDiv);

         $('<input>').attr({
             type: 'hidden',
             id: 'hiddenPrefer' + counter,
             name: 'preferCnList',
             value: inputValue
         }).appendTo('#hiddenPreferList');

         counter++; 
         $('#preferCn').val('');
     } else {
     	alert('우대 조건을 입력하세요.');
     }
 });
});
$(document).ready(function() {
    // 'x' 버튼 클릭 시 해당 input과 div 삭제
    $(document).on('click', '.delBtn5', function() {
        $(this).closest('.prefer-input-del').remove();
    });
});
//-----------------------------------------------복지 및 혜택 추가 
$(document).ready(function() {
 let counter = 0;

 $('.add-btn3').click(function() {
     var inputValue = $('#favor').val();
     
     // 중복 확인 로직
     var isDuplicate = false;
     $('#dynamicList3 div').each(function() {
         if ($(this).text().includes(inputValue)) {
             isDuplicate = true;
         }
     });

     if (isDuplicate) {
         alert('중복된 조건을 입력할 수 없습니다.');
         return;
     }

     if (inputValue) {
         var newDiv = $('<div></div>').text(inputValue);
         var removeBtn = $('<button class="delBtn"><img class="delImg" src="../resources/icon/delete.png"></button>').css({
             marginLeft: '10px',
             cursor: 'pointer'
         });

         removeBtn.click(function() {
             newDiv.remove();
             $('#hiddenFavor' + counter).remove();
         });

         newDiv.append(removeBtn);
         $('#dynamicList3').append(newDiv);

         $('<input>').attr({
             type: 'hidden',
             id: 'hiddenFavor' + counter,
             name: 'favorList',
             value: inputValue
         }).appendTo('#hiddenFavorList');

         counter++;
         $('#favor').val('');
     } else {
         alert('복지 및 혜택을 입력하세요.');
     }
 });
});
$(document).ready(function() {
    // 'x' 버튼 클릭 시 해당 input과 div 삭제
    $(document).on('click', '.delBtn1', function() {
        $(this).closest('.favor-input-del').remove();
    });
});
//-------------------------최저임금제도 모달창
$(document).ready(function() {
  // 모달 열기
  $('.sal-line').click(function() {
    $('#salaryModal').css('display', 'block');
    $('body').css('overflow', 'hidden'); // 배경 스크롤 비활성화
  });

  // 모달 닫기
  $('.close').click(function() {
    $('#salaryModal').css('display', 'none');
    $('body').css('overflow', 'auto'); // 배경 스크롤 다시 활성화
  });

  // 아코디언 버튼 클릭 이벤트
  $('#accordion-btn').click(function() {
    $('#accordion-content').slideToggle();
    $(this).text($(this).text() === '보기' ? '접기' : '보기');
  });
  
  // 확인 버튼 클릭 시 모달 닫기
  $('.modalOk').click(function() {
    $('#salaryModal').css('display', 'none');
    $('body').css('overflow', 'auto'); // 배경 스크롤 다시 활성화
});
  
  // 확인 버튼 클릭 시 히든 제거
  $('.modalGo').click(function() {
    // 히든 섹션 보이도록 설정
    $('section[hidden="hidden"]').attr("hidden", false);
      // 모집 분야로 스크롤
      document.getElementById("pbancInsert").scrollIntoView({
          behavior: 'smooth'
      });
});
  
});
//-------------------------카카오맵 api
$(function(){
	var marker = {
    position: new kakao.maps.LatLng(33.450701, 126.570667), 
    text: "${enterVO.entNm}" 
};

var staticMapContainer  = document.getElementById('staticMap'), // 이미지 지도를 표시할 div
    staticMapOption = { 
        center: new kakao.maps.LatLng(33.450701, 126.570667), // 이미지 지도의 중심좌표
        level: 3, // 이미지 지도의 확대 레벨
        marker: marker // 이미지 지도에 표시할 마커
    };

// 이미지 지도를 생성합니다
var staticMap = new kakao.maps.StaticMap(staticMapContainer, staticMapOption);
});
// 서버에서 받아온 주소를 자바스크립트 변수로 저장
var address = '${location.entAddr}';

// 카카오 지도 API Geocoder 사용
var geocoder = new kakao.maps.services.Geocoder();

// 주소로 좌표를 검색하는 함수
geocoder.addressSearch(address, function(result, status) {
    if (status === kakao.maps.services.Status.OK) {
        var coords = new kakao.maps.LatLng(result[0].y, result[0].x);
        var mapContainer = document.getElementById('staticMap'), 
            mapOption = { 
                center: coords, 
                level: 3
            };

        var map = new kakao.maps.Map(mapContainer, mapOption);

        var marker = new kakao.maps.Marker({
            map: map,
            position: coords
        });
        
     // 인포윈도우로 장소에 대한 설명을 표시합니다
        var infowindow = new kakao.maps.InfoWindow({
            content: '<div style="width:150px;text-align:center;padding:6px 0;">${enterVO.entNm}</div>'
        });
        infowindow.open(map, marker);

        // 지도의 중심을 결과값으로 받은 위치로 이동시킵니다
        map.setCenter(coords);
        
    } else {
        console.error('주소 변환 실패: ' + status); // 오류 로그 추가
    }
});
//-------------------------임시저장 ajax
$(function(){
	
	var Toast = Swal.mixin({
		toast: true,
		position: 'center',
		showConfirmButton: false,
		timer: 3000
		});

    document.getElementById('tempPbancSave').addEventListener('click', function(e) {
        e.preventDefault();
        var entId = $('#entId').val();
        var formData = new FormData(document.getElementById('pbancInsert'));

        console.log("formData : ", formData);
        console.log("entId : ", entId);

        // SweetAlert2 대화상자
        Swal.fire({
            title: '임시 저장하시겠습니까?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: 'white',  // 버튼 색상
            cancelButtonColor: 'white',     // 버튼 색상
            confirmButtonText: '예',
            cancelButtonText: '아니오',
            reverseButtons: false // 버튼 순서 거꾸로
        }).then((result) => {
            if (result.isConfirmed) {
                // "예" 버튼을 눌렀을 때 AJAX 요청 실행
                $.ajax({
                    type : 'POST',
                    url : '/enter/retempPbancSavePost',
                    data : formData,
                    processData: false,
                    contentType: false,
                    beforeSend : function(xhr) {
                        xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                    },
                    success : function(response) {
                        console.log("response", response);
                        Toast.fire({
            				icon:'success',
            				title:'공고가 임시 저장되었습니다.'
                        }).then(() => {
                            location.href = "/enter/tempPbanc?entId=" + entId;
                        });
                    },
                    error : function(error) {
                        console.log('Error:', error);
                    	Toast.fire({
            				icon:'error',
            				title:'공고 임시 저장 중 오류가 발생했습니다.'
                        });
                    }
                });
            }
        });
    });
});

//-------------------------모집업종
$(document).ready(function() {
    // 모집업종 select box에서 선택한 값을 <div>에 넣기
    $('#tpbizCd').change(function() {
        var selectedOptions = [];
        $('#tpbizCd option:selected').each(function() {
            selectedOptions.push($(this).text()); // 선택된 옵션의 텍스트 값을 배열에 추가
        });

        var selectedText = selectedOptions.join(', '); // 여러 개 선택 시 콤마로 구분
        $('#selectedOptionsDiv').text(selectedText); // ID로 지정된 <div>에 선택된 텍스트 값 추가
    });
});


//-----------------------------------------------validation 유효성검사    
$(document).ready(function() {

    // 공고 제목 실시간 유효성 검사
    $('#title').on('keyup', function() {
        let pbancTtl = $(this).val();
        if (!pbancTtl || pbancTtl.length < 5 || pbancTtl.length > 100) {
            showError(this, '공고 제목은 5자 이상 100자 이하이어야 합니다.');
        } else {
            hideError(this);
        }
    });

    // 공고 내용 실시간 유효성 검사
    $('textarea[name="pbancCn"]').on('keyup', function() {
        let pbancCn = $(this).val();
        if (!pbancCn || pbancCn.length < 30) {
            showError(this, '공고 내용은 30자 이상이어야 합니다.');
        } else {
            hideError(this);
        }
    });

    // 에러 메시지 표시 함수
    function showError(selector, message) {
        $(selector).addClass('input-error');  // input 필드에 빨간 테두리 추가
        $(selector).closest('.form-group').find('.error-msg').text(message).show();  // 같은 form-group 내의 error-msg를 찾아서 경고 메시지 표시
    }

    // 에러 메시지 숨기기 함수
    function hideError(selector) {
        $(selector).removeClass('input-error');  // 빨간 테두리 제거
        $(selector).closest('.form-group').find('.error-msg').hide();  // 같은 form-group 내의 error-msg 숨기기
    }
});

//---------------------------------------------공고 등록 버튼 눌렀을 때
$(document).ready(function() {
    // 공고 등록 버튼 클릭 시
    $('.submit-btn').on('click', function(e) {
        e.preventDefault(); // 기본 폼 제출 방지

        // SweetAlert2 대화상자
        Swal.fire({
            title: '등록하시겠습니까?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: 'white', // 예 버튼 색상
            cancelButtonColor: 'white', // 아니오 버튼 색상
            confirmButtonText: '예',
            cancelButtonText: '아니오',
            reverseButtons: false // 버튼 순서 유지
        }).then((result) => {
            if (result.isConfirmed) {
                $('#pbancInsert').submit();
            }
        });
        
        
    });
});

</script>
</html>
