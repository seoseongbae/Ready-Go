package kr.or.ddit.oustou.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.vo.BoardVO;
import kr.or.ddit.vo.CodeGrpVO;
import kr.or.ddit.vo.CodeVO;
import kr.or.ddit.vo.OutsouVO;



public interface OutsouMainService {
	
	/* 메인 부분 */
	public List<OutsouVO> getCategory();//조회수가 많은 카테고리 5개 
	
	public List<OutsouVO> getnewList();//메인 새로운 게시글 5개 
	
	public List<OutsouVO> getBestList();  //메인 조회수 높은글  게시글 5개 (BEST )
	
	//리뷰글 가져오기
	
	
	/* 카테고라별 목록 */
	public List<OutsouVO> getWebList(Map<String, Object> map); //웹제작 목록 + 페이지네이션
	public int getWebTotal(Map<String, Object> map); //웹 행의 수
	//프로그램
	public List<OutsouVO> getPGList(Map<String, Object> map); 
	public int getPGTotal(Map<String, Object> map); 
	//데이터
	public List<OutsouVO> getDataList(Map<String, Object> map); 
	public int getDataTotal(Map<String, Object> map); 
	//AI
	public List<OutsouVO> getAIList(Map<String, Object> map); 
	public int getAITotal(Map<String, Object> map); 
	//직무직군
	public List<OutsouVO> getJobList(Map<String, Object> map);
	public int getJobTotal(Map<String, Object> map); 
	//자기소개서
	public List<OutsouVO> getSIList(Map<String, Object> map); 
	public int getSITotal(Map<String, Object> map); 

	

	public List<CodeVO> getSrleList(); //기술 수준 ㅋ코드 

	public List<CodeVO> getSrteList(); //인재 수준 코드
	
	
	/*검색 결과 목록 */
	public List<OutsouVO> getscarchList(Map<String, Object> map); //검색결과 + 페이지네이션

	public int getscarchTotal(Map<String, Object> map); //전체 행의 수

	/*리뷰 목록 3개 */
	public List<BoardVO> reviewBest();
}
