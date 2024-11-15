package kr.or.ddit.controller_DO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import kr.or.ddit.mapper.AdminMapper;
import kr.or.ddit.mapper.FileDetailMapper;
import kr.or.ddit.mapper.FreeBoardMapper;
import kr.or.ddit.mapper.NotificationMapper;
import kr.or.ddit.mapper.UserMapper;
import kr.or.ddit.security.SocketHandler;
import kr.or.ddit.service_DO.FreeBoardService;
import kr.or.ddit.service_DO.NotificationService;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.util.GetUserUtil;
import kr.or.ddit.vo.BoardVO;
import kr.or.ddit.vo.CodeVO;
import kr.or.ddit.vo.CommentVO;
import kr.or.ddit.vo.DeclarationVO;
import kr.or.ddit.vo.FileDetailVO;
import kr.or.ddit.vo.MemberVO;
import kr.or.ddit.vo.NotificationVO;
import lombok.extern.slf4j.Slf4j;


@RequestMapping("/common/freeBoard")
@Controller
@Slf4j
public class ComFreeController {

	@Inject
	FreeBoardService freeBoardService;
	
	@Autowired
	UserMapper userMapper;
	
	@Inject
	FileDetailMapper fileDetailMapper;
	
	@Inject
	AdminMapper adminMapper;
	
	@Inject
	GetUserUtil getUserUtil;
	
	@Inject
	NotificationService notificationService;
	
    @Autowired
    private SocketHandler socketHandler;
    

    @RequestMapping(value="/freeList", method=RequestMethod.GET)
    public ModelAndView admList(ModelAndView mav,
            @RequestParam(value="currentPage", required=false, defaultValue="1") int currentPage,
            @RequestParam(value="pstOthbcscope", required=false, defaultValue="") String pstOthbcscope,
            @RequestParam(value="searchKeyword", required=false, defaultValue="") String searchKeyword,
            RedirectAttributes redirectAttributes) {
        List<CodeVO> codeVOList = userMapper.codeSelect("FBOD");
        log.info("codeVOList", codeVOList);
        
        mav.addObject("codeVOList", codeVOList);
        
        Map<String, Object> map = new HashMap<>();
        map.put("currentPage", currentPage);
        map.put("pstOthbcscope", pstOthbcscope);
        map.put("searchKeyword", "%" + searchKeyword + "%"); 

        log.info("list->map : " + map);
        
        List<BoardVO> boardVOList = this.freeBoardService.admList(map);
        
        int total = this.freeBoardService.getTotal(map);
        
        // 검색어와 필터값을 ModelAndView에 추가
        mav.addObject("searchKeyword", searchKeyword);
        mav.addObject("pstOthbcscope", pstOthbcscope);

        // 페이지네이션 객체
        ArticlePage<BoardVO> articlePage = new ArticlePage<>(total, currentPage, 10, boardVOList, searchKeyword, pstOthbcscope);
        log.info("articlePage : " + articlePage);
        
        // 로그인한 사용자 ID 가져오기
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String mbrId = authentication.getName();
        mav.addObject("loggedInUser", mbrId);
        
        mav.addObject("articlePage", articlePage);
        mav.setViewName("common/freeBoard/freeList");
        String loggedInUser = "anonymousUser";  // 기본 값 설정
        	
        if (authentication != null && authentication.isAuthenticated() && !(authentication instanceof AnonymousAuthenticationToken)) {
            loggedInUser = authentication.getName();
            mav.addObject("loggedInUser", loggedInUser);
            MemberVO memVO = getUserUtil.getMemVO();
            if(memVO == null) {
            	mav.setViewName("common/freeBoard/freeList");
            }else {
            // 알림 목록 조회
            List<NotificationVO> alramList = notificationService.alramList(loggedInUser);
            mav.addObject("alramList", alramList);  
			//알림 데이터 모델에 추가
            mav.addObject("alramList", alramList);	
            // 로그인한 사용자의 경고 횟수를 체크
            memVO = getUserUtil.getMemVO();
	            if (memVO.getMbrWarnCo() > 4) {
	                redirectAttributes.addFlashAttribute("alertMessage", "게시판 제한자입니다");
	                return new ModelAndView("redirect:/"); // 루트 페이지로 리다이렉트
	            }
            }
        }

        return mav;
    }

	
	@GetMapping("/freeRegist")
	public String regist(Model model) {
	    List<CodeVO> codeVOList = userMapper.codeSelect("FBOD");
	    log.info("codeVOList", codeVOList);
	    
	    model.addAttribute("codeVOList", codeVOList);
	  //웹소켓 알림설정 
	  //로그인한 사용자 ID 가져오기
	  Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
	  String loggedInUser = "anonymousUser";  // 기본 값 설정

	  if (authentication != null && authentication.isAuthenticated() && !(authentication instanceof AnonymousAuthenticationToken)) {
			loggedInUser = authentication.getName();
			model.addAttribute("loggedInUser", loggedInUser);
			//알림 목록 조회
			List<NotificationVO> alramList = notificationService.alramList(loggedInUser);
					
			//알림 데이터 모델에 추가
			model.addAttribute("alramList", alramList);	        
	    };    
	    return "common/freeBoard/freeRegist";
	}

	
	@PostMapping("/freeRegistPost")
	public String registPost(@ModelAttribute BoardVO boardVO) {
	    // 로그인한 사용자 정보 가져오기
	    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
	    String mbrId = authentication.getName();  // 로그인한 사용자 이름 (id)
	    
	    // boardVO의 작성자(writer) 필드에 로그인한 사용자 설정
	    boardVO.setMbrId(mbrId);
	    
	    String fileGroupSn = this.fileDetailMapper.getFileGroupSn();
	    boardVO.setFileGroupSn(fileGroupSn);  
	    
	    log.info("registPost->boardVO : " + boardVO);
	    int result = this.freeBoardService.admRegistPost(boardVO);
	    log.info("registPost->result : " + result);
	    
	    return "redirect:/common/freeBoard/freeDetail?seNo=3"+ "&pstSn=" + boardVO.getPstSn();
	}
	
	@PostMapping("/updatePost")
	public String updatePost(@ModelAttribute BoardVO boardVO) {
	    log.info("updatePost -> boardVO : " + boardVO);

	    String fileGroupSn = this.fileDetailMapper.getFileGroupSn();
	    boardVO.setFileGroupSn(fileGroupSn);  
	    // 수정된 데이터 업데이트
	    int result = this.freeBoardService.updatePost(boardVO);
	    
	    return "redirect:/common/freeBoard/freeDetail?seNo=3&pstSn=" + boardVO.getPstSn();

	}
	
	@GetMapping("/freeUpdate")
	public String update(@RequestParam("pstSn") String pstSn, Model model) {
	    log.info("update => get pstSn : " + pstSn);
	    List<CodeVO> codeVOList = userMapper.codeSelect("FBOD");
	    log.info("codeVOList", codeVOList);
	    
	    // 게시글 상세 정보 가져오기
	    BoardVO boardVO = this.freeBoardService.getPostDetails(pstSn);
	    model.addAttribute("boardVO", boardVO);
	    model.addAttribute("codeVOList", codeVOList);
	    String fileGroupSn = this.fileDetailMapper.getFileGroupSn();
	    model.addAttribute(fileGroupSn);
	    // 파일 상세 정보 가져오기
	    List<FileDetailVO> fileDetails = this.freeBoardService.getFileDetailsByPstSn(pstSn);
	    model.addAttribute("fileDetails", fileDetails);  // 파일 상세 정보 추가
	    
	  //웹소켓 알림설정 
	  //로그인한 사용자 ID 가져오기
	  Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
	  String loggedInUser = "anonymousUser";  // 기본 값 설정

	  if (authentication != null && authentication.isAuthenticated() && !(authentication instanceof AnonymousAuthenticationToken)) {
			loggedInUser = authentication.getName();
			model.addAttribute("loggedInUser", loggedInUser);
	        // 게시글 작성자와 로그인한 사용자가 같은지 확인
	        if (!loggedInUser.equals(boardVO.getMbrId())) {
	            // 권한이 없는 경우 접근 차단 및 경고 메시지 설정
	            return "redirect:/common/freeBoard/freeList";  
	        }
			//알림 목록 조회
			List<NotificationVO> alramList = notificationService.alramList(loggedInUser);
					
			//알림 데이터 모델에 추가
			model.addAttribute("alramList", alramList);	        
	    }else {
	        // 비로그인 사용자의 경우 접근 차단
	        return "redirect:/security/login";  
	    }
	    
	    return "common/freeBoard/freeUpdate";  // 수정 페이지로 이동
	}
	
	@GetMapping("/freeDetail")
	public String detail(@RequestParam("pstSn") String pstSn, Model model) {
	    log.info("detail=> getpstSn : "+pstSn);
	    List<CodeVO> codeVOList = userMapper.codeSelect("WARN");
	    log.info("codeVOList", codeVOList);
	    
	    model.addAttribute("codeVOList", codeVOList);

	    // 상세정보 가져오기
	    BoardVO boardVO = this.freeBoardService.admDetail(pstSn);
	    model.addAttribute("boardVO", boardVO);
	    
	    // 댓글 목록 가져오기
	    List<CommentVO> commentsList = this.freeBoardService.getComments(pstSn);
	    model.addAttribute("commentsList", commentsList);

	    // 파일 상세 정보 가져오기
	    List<FileDetailVO> fileDetails = this.freeBoardService.getFileDetailsByPstSn(pstSn);
	    model.addAttribute("fileDetails", fileDetails);  // 파일 상세 정보 추가
	    
	    // 로그인한 사용자 ID 가져오기
	    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
	    String loggedInUser = "anonymousUser";  // 기본 값 설정
	    
	    if (authentication != null && authentication.isAuthenticated() && !(authentication instanceof AnonymousAuthenticationToken)) {
	        loggedInUser = authentication.getName();
	        model.addAttribute("loggedInUser", loggedInUser);
	    }
	    
	    // 작성자와 로그인한 사용자 비교, 다를 경우에만 조회수 증가
	    if (!loggedInUser.equals(boardVO.getMbrId())) {
	        this.freeBoardService.InqCnt(pstSn);
	    }
	    
	    //게시판제한 경고 및 비로그인은 접근가능
	    if (authentication != null && authentication.isAuthenticated() && !(authentication instanceof AnonymousAuthenticationToken)) {
	        loggedInUser = authentication.getName();
	        model.addAttribute("loggedInUser", loggedInUser);
	        MemberVO memVO = getUserUtil.getMemVO();
	        if(memVO == null) {
	        	return "common/freeBoard/freeDetail";  
	        }else {
	  			//알림 목록 조회
	  			List<NotificationVO> alramList = notificationService.alramList(loggedInUser);
	  					
	  			//알림 데이터 모델에 추가
	  			model.addAttribute("alramList", alramList);	
		        // 로그인한 사용자의 경고 횟수를 체크
		        memVO = getUserUtil.getMemVO();
			    if(memVO.getMbrWarnCo() > 4) {
			    	model.addAttribute("alertMessage", "게시판 제한자입니다");
			    	return "home";
			    }
	        }
	    }
	    
	    
	    return "common/freeBoard/freeDetail";  
	}
	
	@PostMapping("/registReplyPost")
	public String registReplyPost(@RequestParam("commentContent") String commentContent, @RequestParam("pstSn") String pstSn,HttpServletRequest request) {
	    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
	    String mbrId = authentication.getName();  // 로그인한 사용자 이름

	    CommentVO commentVO = new CommentVO();
	    commentVO.setCmntCn(commentContent);
	    commentVO.setPstSn(pstSn);
	    commentVO.setMbrId(mbrId);
	    commentVO.setCmntDelYn("1");

	    int result = this.freeBoardService.registComment(commentVO);
	    log.info("registReplyPost->result : " + result);

	    if (result > 0) {
	        String boardWriter = freeBoardService.getBoardWriter(pstSn); // 게시글 작성자 ID
	        log.info("게시글 작성자 ID: " + boardWriter);

	        // WebSocket 메시지 포맷
	        String websocketMessage = String.format("%s님이 작성하신 자유게시글에 댓글을 달았습니다!", mbrId); // 제목은 적절하게 가져와서 사용
	        // 현재 URL
            String currentUrl = "/common/freeBoard/freeDetail?pstSn=" + pstSn;
	        // WebSocket 세션 체크 후 메시지 전송
	        log.info("boardWriter: " + boardWriter);
	        log.info("현재 등록된 세션 목록: " + socketHandler.getUserSessionsMap().keySet());

	        if(!boardWriter.equals(mbrId)) {
		        if (socketHandler.getUserSessionsMap().containsKey(boardWriter)) {
		            socketHandler.sendMessageToUser(boardWriter, websocketMessage);
		        } else {
		            log.warn("WebSocket 세션을 찾을 수 없음, 사용자: " + boardWriter);
		            log.info("현재 등록된 세션 목록: " + socketHandler.getUserSessionsMap().keySet());
		        }
		        //알림 저장
		        NotificationVO notificationVO = new NotificationVO();
		        notificationVO.setCommonId(boardWriter); // 게시글 작성자 ID
		        notificationVO.setNtcnCn(websocketMessage); // 알림 메시지 내용
		        notificationVO.setNtcnUrl(currentUrl); // 알림과 연결된 URL
		        this.notificationService.sendAlram(notificationVO);  // 알림 저장	        
	        }
	    }

	    return "redirect:/common/freeBoard/freeDetail?pstSn=" + pstSn;
	}


    @PostMapping("/updateComment")
    @ResponseBody
    public String updateComment(@RequestBody CommentVO commentVO) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String mbrId = authentication.getName();

        // 댓글 수정 처리
        commentVO.setMbrId(mbrId);
        int result = this.freeBoardService.updateComment(commentVO);
        return result > 0 ? "success" : "fail";
    }
    
    @PostMapping("/deleteComment")
    @ResponseBody
    public String deleteComment(@RequestParam("cmntNo") String cmntNo, @RequestParam("pstSn") String pstSn) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String mbrId = authentication.getName();

        // 댓글 삭제 처리
        int result = this.freeBoardService.deleteComment(cmntNo, pstSn, mbrId);
        return result > 0 ? "success" : "fail";
    }
    
	@PostMapping("/deletePost")
	public String deletePost(@RequestParam("pstSn") String pstSn) {
	    log.info("deletePost -> getpstSn : " + pstSn);
	    
	    // 게시글 삭제
	    int result = freeBoardService.deletePost(pstSn); // 서비스에서 게시글 삭제
	    if (result > 0) {
	        log.info("게시글 삭제 성공");
	    } else {
	        log.info("게시글 삭제 실패");
	    }
	    
	    return "redirect:/common/freeBoard/freeList"; // 삭제 후 목록 페이지로 리디렉션
	}
	
	
	@PostMapping("/boardReport")
	@ResponseBody
	public String boardReport(@RequestBody DeclarationVO declarationVO) {
	    int result = freeBoardService.boardReport(declarationVO); 
	    return result > 0 ? "success" : "fail"; 
	}
	@PostMapping("/replyReport")
	@ResponseBody
	public String replyReport(@RequestBody DeclarationVO declarationVO) {
		int result = freeBoardService.replyReport(declarationVO); 
		return result > 0 ? "success" : "fail"; 
	}

	@GetMapping("replyPage")
	@ResponseBody
	public List<CommentVO> replyPage(String pstSn, int page, int size) {
	    int startRow = (page - 1) * size + 1;
	    int endRow = page * size;
	    
	    Map<String, Object> paramMap = new HashMap<>();
	    paramMap.put("pstSn", pstSn);
	    paramMap.put("startRow", startRow);
	    paramMap.put("endRow", endRow);
	    
	    return freeBoardService.replyPage(paramMap);
	}
	
	
}
