package kr.or.ddit.mapper;

import java.util.List;

import kr.or.ddit.vo.CodeVO;
import kr.or.ddit.vo.OsClVO;
import kr.or.ddit.vo.OsDevalVO;
import kr.or.ddit.vo.OsKeywordVO;
import kr.or.ddit.vo.OsdeCludVO;
import kr.or.ddit.vo.OsdeDatabaseVO;
import kr.or.ddit.vo.OsdeLangVO;
import kr.or.ddit.vo.OutsouVO;

public interface OutsouMapper {

	//공통코드 
	public List<CodeVO> cacodeSelect(String comCode);
	
	//외주 테이블 저장  -->
	public int insertOutsou(OutsouVO oustouVO);
	
	//외주 개발 서비스 저장   -->
	public int insertOsDeval(OsDevalVO oustouDevalVO);
	
	//언어코드 저장 
	public int insertOsdeLang(OsdeLangVO osdeLangVO);
	//데이터베이스 저장
	public int insertOsdeDatabase(OsdeDatabaseVO osdeDatabaseV);
	//클라우드 저장
	public int insertOsdeClud(OsdeCludVO osdeCludVO);
	
	//외주 자소서 서비스 저장  -->
	public int insertOsCl(OsClVO oustouClVO);
	
	//외주 키워트 저장 
	public int insertOsKeywoed(OsKeywordVO osKeywordVO);
	
	//외주 상세 
	public OutsouVO selectDetail(String outsordNo);
	
	//외주 만든 담당자
	public OutsouVO getOutsouMem(String outsordNo);

	
	//게시판 조회수 업데이트
	public void upCnt(String outsordNo);
	
	//외주 테이블 업데이트 
	public int updateOutsou(OutsouVO outsouVO);
	
	//외주 개발 서비스 업데이트  
	public int updateOsDeval(OsDevalVO osDevalVO);
	
	//언어코드 업데이트
	public int updateOsdeLang(OsdeLangVO osdeLangVO);
	
	//데이터베이스 업데이트
	public int updateOsdeDatabase(OsdeDatabaseVO osdeDatabaseVO);
	
	//클라우드 업데이트
	public int updateOsdeClud(OsdeCludVO osdeCludVO);
	
	//외주 자소서 서비스 업데이트
	public int updateOsCl(OsClVO outsouClVO);
	
	//외주 키워트 저장 
	public int updateOsKeywoed(OsKeywordVO osKeywordVO);
	
	//외주 삭제 
	public int deletePost(String outsordNo);
	
	//언어코드 삭제
	public int deleteOsdeLang(String outsordNo);
	
	//데이터베이스 삭제
	public int deleteOsdeDatabase(String outsordNo);
	
	//클라우드 삭제
	public int deleteOsdeClud(String outsordNo);
	
	//외주 키워트 삭제
	public int deleteOsKeywoed(String outsordNo);

	public String Writer(String outordNo);

	
	


	
}
