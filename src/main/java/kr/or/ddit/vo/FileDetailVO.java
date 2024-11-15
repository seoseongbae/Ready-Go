package kr.or.ddit.vo;

import java.util.Date;

import lombok.Data;

@Data
public class FileDetailVO {
	private String fileGroupSn;
	private String gubun;
	private int fileSn;
	private String orgnlFileNm;
	private String strgFileNm;
	private String filePathNm;
	private long fileSz;
	private String fileExtnNm;
	private String fileMime;
	private String fileFancysize;
	private Date fileStrgYmd;
	private int fileDwnldCnt;
}
