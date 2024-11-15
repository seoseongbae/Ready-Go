package kr.or.ddit.enter.entservice.impl;

import java.util.Map;

import javax.inject.Inject;

import org.apache.commons.mail.DefaultAuthenticator;
import org.apache.commons.mail.EmailAttachment;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.MultiPartEmail;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.enter.entservice.EmailService;
import kr.or.ddit.mapper.EnterMapper;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.EnterVO;
import kr.or.ddit.vo.FileDetailVO;
import lombok.extern.slf4j.Slf4j;
@Transactional
@Slf4j
@Service
public class EmailServiceImpl implements EmailService {
    private final String hostName = "smtp.gmail.com";
    private final int smtpPort = 587;
//    private final String username = "minju990219@gmail.com"; // 발신자 이메일
//    private final String password = "kvup pdyc pgew ngtb"; // 구글 앱 비밀번호
    @Inject
    EnterMapper enterMapper;
    
    @Inject //파일 처리
    private UploadController uploadController;
    
    public void sendEmail(Map<String,Object> map) throws EmailException {
    
    	EnterVO entVO = this.enterMapper.getEntInfo(map);
    	log.info("subject : "+(String) map.get("subject"));
    	log.info("message : "+(String) map.get("message"));
    	log.info("entId : "+(String) map.get("entId"));
    	log.info("mbrId : "+(String) map.get("mbrId"));
    	log.info("recipientEmail : "+(String) map.get("recipientEmail"));
    	log.info("entVO : "+entVO);
    	
    	String username = entVO.getEntMail(); // 발신자 이메일
    	String password = entVO.getEntMailApppswd(); // 구글 앱 비밀번호
    	// 이메일 객체 생성
        MultiPartEmail email = new MultiPartEmail();
    	MultipartFile[] uploadFile = (MultipartFile[]) map.get("file");
    	log.info("uploadFile : "+uploadFile);
    	log.info("uploadFile.length : " + uploadFile.length);
    	log.info("uploadFile[0].isEmpty() :  " + uploadFile[0].isEmpty());
    	if (uploadFile == null || uploadFile.length == 0 || uploadFile[0].isEmpty()) {
			log.info("새로운 파일이 업로드되지 않았습니다.");
    	}else {
    		String fileGroupNo = this.uploadController.multiImageUpload(uploadFile, "/enter/scout");    		
    		map.put("fileGroupNo",fileGroupNo);
    		FileDetailVO fileDetailVO = this.enterMapper.getfilePath(map);
//          첨부파일 생성을 위한 EmailAttachment 객체 생성
            EmailAttachment attachment = new EmailAttachment();
            attachment.setName(fileDetailVO.getOrgnlFileNm()); //첨부파일의 이름설정
            attachment.setDescription("이미지 입니다.");
           
            String sendName = fileDetailVO.getFilePathNm().replace("https://readygo0729.s3.ap-northeast-2.amazonaws.com/", "/upload/");
            attachment.setPath(sendName);
            attachment.setDisposition(EmailAttachment.ATTACHMENT);
            email.attach(attachment);
    	}

//       Email email = new SimpleEmail();
        email.setHostName(hostName);
        email.setSmtpPort(smtpPort);
        email.setAuthenticator(new DefaultAuthenticator(username, password));
        email.setStartTLSRequired(true);
        email.setFrom(username); // 발신자 이메일

        email.setSubject((String) map.get("subject")); // 메일 제목"
//        email.setSubject("메일 제목"); // 메일 제목
        
//        email.setMsg("메일 내용"); // 메일 내용
//        email.addTo("lovely3529@naver.com"); // 수신자 이메일
        email.setMsg((String) map.get("message")); // 메일 내용
        email.addTo((String) map.get("recipientEmail")); // 수신자 이메일
        
        email.send(); // 메일 전송
        
        this.enterMapper.setProposal(map);
    }
}
