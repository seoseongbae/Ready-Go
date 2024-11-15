package kr.or.ddit.oustou.service;

import java.util.List;

import kr.or.ddit.vo.CodeVO;
import kr.or.ddit.vo.OsClVO;
import kr.or.ddit.vo.OsDevalVO;
import kr.or.ddit.vo.OsKeywordVO;
import kr.or.ddit.vo.OsdeCludVO;
import kr.or.ddit.vo.OsdeDatabaseVO;
import kr.or.ddit.vo.OsdeLangVO;
import kr.or.ddit.vo.OutsouVO;



public interface OutsouService {
	
	//<!--  외주 등록  -->
	public int registPostAjax( OutsouVO outsouVO);
	
	//외주 상세 
	public OutsouVO detail(String outsordNo);
	//외주 만든 담당자
	public OutsouVO getOutsouMem(String outsordNo);

	//외주 구매페이지 
	public OutsouVO paydetail(String outsordNo);
	
	
	//외주 삭제 
	public int deletePost(String outsordNo);
	
	
	//외주 테이블 업데이트 
	public int updatePost(OutsouVO outsouVO);

	public String Writer(String outordNo);
	
	
}
