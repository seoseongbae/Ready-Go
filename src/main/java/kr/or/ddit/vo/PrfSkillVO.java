package kr.or.ddit.vo;

import lombok.Data;

// 프로필 스킬
@Data
public class PrfSkillVO {
	private String skCd;	// 스킬 번호
	private String mbrId;	// 회원 아이디
	
	private String skNm; 	// 스킬 이름
	
	// 스킬 => 여러 개 받기 때문에 배열로 받아야 한다.
	private String[] skill; 
	private String skillStr;	

}
