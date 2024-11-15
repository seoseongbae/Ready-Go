package kr.or.ddit.controller;

import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import kr.or.ddit.service.NonService;
import kr.or.ddit.vo.EnterVO;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequestMapping("/enterMem")
public class NonController {
	
	@Inject
	NonService nonService;
	
	
	
	// 기업권한 수락/거절
    @GetMapping("/acceptPage")
    public ModelAndView acceptPage(ModelAndView mav) {
    	
        // 뷰 리졸버
        mav.setViewName("enterMem/acceptPage");
        
        return mav;
    }
    
    //폼 전송시
    @PostMapping("/acceptSuccess")
    public String acceptSuccess(Model model,
    		@RequestParam("entNm") String entNm,
    		@RequestParam("mbrId") String mbrId) {
    	
    	log.info("entNm : "+entNm);
    	log.info("mbrId : "+mbrId);
    	
    	Map<String,Object> map = new HashMap<String,Object>();
    	map.put("entNm", entNm);
    	map.put("mbrId", mbrId);
    	
    	EnterVO enterVO = this.nonService.enterSearch(map);
    	log.info("entVO : "+enterVO);
    	map.put("entId",enterVO.getEntId());
    	
    	this.nonService.updateMem(map);
    	
    	
    	return "redirect:/";
    }
    
    @PostMapping("/acceptDel")
    public String acceptDel(Model model,
    		@RequestParam("entNm") String entNm,
    		@RequestParam("mbrId") String mbrId) {
    	
    	Map<String,Object> map = new HashMap<String,Object>();
    	map.put("entNm", entNm);
    	map.put("mbrId", mbrId);
    	EnterVO enterVO = this.nonService.enterSearch(map);
    	log.info("entVO : "+enterVO);
    	map.put("entId",enterVO.getEntId());
    	this.nonService.deleteEntmem(map);
    	
		return "redirect:/";
    	
    }
    
    
}
