package kr.or.ddit.service.impl;

import java.util.Map;

import javax.inject.Inject;

import org.springframework.stereotype.Service;

import kr.or.ddit.mapper.NonMapper;
import kr.or.ddit.service.NonService;
import kr.or.ddit.vo.EnterVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class NonServiceImpl implements NonService{
	
	@Inject
	NonMapper nonMapper;
	
	@Override
	public EnterVO enterSearch(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return this.nonMapper.enterSearch(map);
	}

	@Override
	public void updateMem(Map<String, Object> map) {
		this.nonMapper.updateMem(map);
		
		this.nonMapper.roleMem(map);            
		
	}

	@Override
	public void deleteEntmem(Map<String, Object> map) {
		this.nonMapper.deleteEntmem(map);
		
	}
	
}
