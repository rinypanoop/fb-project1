package com.csu.rest;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;


@Controller
@RequestMapping("/")
public class ImageProcessingController {


	@GetMapping("/")
	public String index(Model model) {
		return "index";
	}

	@PostMapping("/home")
	public String home(Model model, HttpServletRequest request, HttpServletResponse response) {
		System.out.println(request.getParameter("access_token"));

		model.addAttribute("access_token", request.getParameter("access_token"));
		model.addAttribute("user_name", request.getParameter("user_name"));
		model.addAttribute("user_id", request.getParameter("user_id"));
		return "home";
	}
	
	@GetMapping(value = "/images")
	public String getAllEmployees(Model model, @RequestParam String fromDate, @RequestParam String toDate){
		
		System.out.println(fromDate);
		System.out.println(toDate);
		
		Employee e = new Employee();
		e.name ="Anoop";
		
		model.addAttribute("employee", e);
		
		return "jsonview";
	}
	
	
}
