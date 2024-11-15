package kr.or.ddit.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import kr.or.ddit.mapper.MemInterViewMapper;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.util.CodeSelect;
import kr.or.ddit.util.GetUserUtil;
import kr.or.ddit.vo.ApplicantVO;
import kr.or.ddit.vo.CodeVO;
import kr.or.ddit.vo.InterViewVO;
import lombok.extern.slf4j.Slf4j;

@RequestMapping("/member")
@Slf4j
@Controller
@PreAuthorize("hasAnyRole('ROLE_MEMBER','ROLE_MEMENTER','ROLE_ENTER')")
public class MemInterViewController {
	
	@Inject
	MemInterViewMapper memInterViewMapper;
	
	@Inject
	GetUserUtil getUserUtil;
	
	@Inject
	CodeSelect codeSelect;
	
	@GetMapping("/interView")
	public String interView(Model model,
    		@RequestParam(value="currentPage",required=false, defaultValue="1")Integer currentPage,
    		@RequestParam(value="state",required=false, defaultValue="") String state,
    		@RequestParam(value="state2",required=false, defaultValue="") String state2,
    		@RequestParam(value="keywordInput",required=false, defaultValue="")String keywordInput) {
		log.info("weafew : " + state);
		// 면접 정보를 구하기 위해 회원 정보 페이징과 검색을 위한 정보 세팅
		Map<String, Object> map = new HashMap<String, Object>();
		String mbrId = getUserUtil.getLoggedInUserId();
		map.put("mbrId", mbrId);
		map.put("currentPage", currentPage);
        map.put("keywordInput", keywordInput);
        map.put("state", state);
        map.put("state2", state2);
        map.put("size", 5);
        // 면접 상태 카운트
        Map<String, Object> map2 = new HashMap<String, Object>();
        map2.put("mbrId", mbrId);
        int InstTotal1 = memInterViewMapper.getInstTotalBefore(map2);
        int InstTotal2 = memInterViewMapper.getInstTotalNow(map2);
        int InstTotal3 = memInterViewMapper.getInstTotalAfter(map2);
		List<InterViewVO> interViewVOList = memInterViewMapper.selectInterViewList(map);
		int total = memInterViewMapper.getTotal(map);
		 // 페이지네이션 객체
        ArticlePage<InterViewVO> articlePage = new ArticlePage<InterViewVO>(total, currentPage, 5, interViewVOList, map);
        
        List<CodeVO> codeList = codeSelect.codeSelect("INST");
        List<CodeVO> codeList2 = codeSelect.codeSelect("PRPR");
		
        model.addAttribute("articlePage", articlePage);
        model.addAttribute("InstTotal1", InstTotal1);
        model.addAttribute("InstTotal2", InstTotal2);
        model.addAttribute("InstTotal3", InstTotal3);
        model.addAttribute("codeList", codeList);
        model.addAttribute("codeList2", codeList2);
		return "member/mypage/interVIewList";
	}
	
	@GetMapping("/video")
	public String videoInterView(Model model,
    		@RequestParam(value="currentPage",required=false, defaultValue="1")Integer currentPage,
    		@RequestParam(value="state",required=false, defaultValue="") String state,
    		@RequestParam(value="state2",required=false, defaultValue="") String state2,
    		@RequestParam(value="keywordInput",required=false, defaultValue="")String keywordInput) {
		log.info("weafew : " + state);
		// 면접 정보를 구하기 위해 회원 정보 페이징과 검색을 위한 정보 세팅
		Map<String, Object> map = new HashMap<String, Object>();
		String mbrId = getUserUtil.getLoggedInUserId();
		map.put("mbrId", mbrId);
		map.put("currentPage", currentPage);
        map.put("keywordInput", keywordInput);
        map.put("state", state);
        map.put("size", 5);
        // 면접 상태 카운트
        Map<String, Object> map2 = new HashMap<String, Object>();
        map2.put("mbrId", mbrId);
        int InstTotal1 = memInterViewMapper.getInstVideoTotalBefore(map2);
        int InstTotal2 = memInterViewMapper.getInstVideoTotalNow(map2);
        int InstTotal3 = memInterViewMapper.getInstVideoTotalAfter(map2);
		List<InterViewVO> interViewVOList = memInterViewMapper.selectVideoList(map);
		int total = memInterViewMapper.getVideoTotal(map);
		 // 페이지네이션 객체
        ArticlePage<InterViewVO> articlePage = new ArticlePage<InterViewVO>(total, currentPage, 5, interViewVOList, map);
        
        List<CodeVO> codeList = codeSelect.codeSelect("INST");
        List<CodeVO> codeList2 = codeSelect.codeSelect("PRPR");
		
        model.addAttribute("articlePage", articlePage);
        model.addAttribute("InstTotal1", InstTotal1);
        model.addAttribute("InstTotal2", InstTotal2);
        model.addAttribute("InstTotal3", InstTotal3);
        model.addAttribute("codeList", codeList);
        model.addAttribute("codeList2", codeList2);
		return "member/mypage/videointrvw";
	}
}
