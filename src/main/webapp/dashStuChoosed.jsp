<%@ page language="java" contentType="text/html; charset=BIG5"
    pageEncoding="utf-8"%>
<%@ page import="fcu.selab.progedu.conn.Conn,fcu.selab.progedu.conn.HttpConnect, fcu.selab.progedu.conn.StudentConn" %>
<%@ page import="fcu.selab.progedu.jenkins.JenkinsApi, fcu.selab.progedu.conn.Language" %>
<%@ page import="fcu.selab.progedu.config.CourseConfig" %>
<%@ page import="fcu.selab.progedu.config.GitlabConfig" %>
<%@ page import="fcu.selab.progedu.config.JenkinsConfig" %>
<%@ page import="fcu.selab.progedu.db.UserDbManager, fcu.selab.progedu.db.ProjectDbManager" %>
<%@ page import="fcu.selab.progedu.data.User, fcu.selab.progedu.data.Project" %>   
<%@ page import="org.gitlab.api.GitlabAPI" %>
<%@ page import="org.gitlab.api.models.*" %>
<%@ page import="java.util.*, fcu.selab.progedu.conn.Dash" %>
<%@ page import="fcu.selab.progedu.jenkins.JobStatus" %>

<%
	if(session.getAttribute("username") == null || session.getAttribute("username").toString().equals("")){
		response.sendRedirect("index.jsp");
	}
	session.putValue("page", "dashStuChoosed");
%>

<%@ include file="language.jsp" %>

<%
	String studentId = request.getParameter("studentId");
	if(null == studentId){
	  response.sendRedirect("index.jsp");
	}
%>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<style type="text/css">
		html, body{
			height: 100%;
		}
		#inline p {
		    display: inline;
		}
		#inline{
			margin: 20px;
		}
		.sidebar {
			background-color: #444;
			color: white;
			margin: -1px;
		}
		.ovol {
			border-radius: 5px;
			height: 50px;
            font-weight: bold;
            width: 120px;
            color: white;
            text-align: center;
		}
		.circle {
			border-radius: 30px;
			height: 30px;
            font-weight: bold;
            width: 30px;
            color: white;
            text-align: center;
		}
        .red {
			background: #e52424;
		}
		.blue {
			background: #258ce8;
		}
		.gray {
			background: #878787;
		}
		.orange {
			background: #FF5809;
		}
		.green {
			background: #32CD32;
		}
		.gold{
			background: #FFD700;
		}
		.circle a {
			color: #fff;
		}
	</style>
	
	<link rel="shortcut icon" href="img/favicon.ico"/>
	<link rel="bookmark" href="img/favicon.ico"/>
	<title>ProgEdu</title>
</head>
<body>
	
	<%
		Conn conn = Conn.getInstance();
	
		UserDbManager db = UserDbManager.getInstance();
		ProjectDbManager Pdb = ProjectDbManager.getInstance();
		
		// Get all db users
		List<User> users = db.listAllUsers();
		
		// Get all db projects
		List<Project> dbProjects = Pdb.listAllProjects();
		
		// gitlab jenkins course data
		GitlabConfig gitData = GitlabConfig.getInstance();
		JenkinsConfig jenkinsData = JenkinsConfig.getInstance();
		CourseConfig courseData = CourseConfig.getInstance();
		
		JenkinsApi jenkins = JenkinsApi.getInstance();
		
		// Get the choosed user
		User choosedUser = new User();
     	for(User user : users){
     		if(studentId.equals(String.valueOf(user.getGitLabId()))){
     			choosedUser = user;
     		    break;
     		}
     	}
	%>
	<%@ include file="header.jsp" %>
	<div class="container-fluid">
		<div class="row">
				<!-- -----sidebar----- -->
				<nav class="col-sm-3 col-md-2 hidden-xs-down bg-faded sidebar">
					<ul class="nav flex-column" style="padding-top: 20px;">
          			  <li class="nav-item">
            				<font size="4"><a style="color: white;" href="javascript:;" data-toggle="collapse" data-target="#projects" class="nav-link"><i class="fa fa-bars" aria-hidden="true"></i>&nbsp; <%=choosedUser.getUserName() %> <i class="fa fa-chevron-down" aria-hidden="true"></i></a></font>
            				<ul id="projects" class="collapse" style="list-style: none;">
	        			            <%
	        			        		List<GitlabProject> projects = conn.getProject(choosedUser);
	        			        		Collections.reverse(projects);
						            	for(GitlabProject project : projects){
						            	  for(Project dbProject : dbProjects){
						            	    if(project.getName().equals(dbProject.getName())){
						            	      String href = "dashProjectChoosed.jsp?userId=" + choosedUser.getGitLabId() + "&proName=" + project.getName();
						            	      %>
						            	      	<li class="nav-item"><font size="3"><a style="color: white;" class="nav-link" href=<%=href %>><i class="fa fa-angle-right" aria-hidden="true"></i>&nbsp; <%=project.getName() %></a></font></li>
						            	      <%
						            	    }
						            	  }
						            	}
						            %>
	    			        </ul>
         			   </li>
         			   <li class="nav-item">
         			       <font size="4"><a style="color: white;" href="javascript:;" data-toggle="collapse" data-target="#student" class="nav-link"><i class="fa fa-bars" aria-hidden="true"></i>&nbsp; <fmt:message key="dashboard_a_student"/> <i class="fa fa-chevron-down" aria-hidden="true"></i></a></font>
        			        <ul id="student" class="collapse show" style="list-style: none;">
        			            <%
		  				          	for(User user : users){
		        			            String style = "color: white;";
			  			          	    String userName = user.getUserName();
			            	 			String href = "\"dashStuChoosed.jsp?studentId=" + user.getGitLabId() + "\"";
			            	 			if(choosedUser.getUserName().equals(user.getUserName())) {
			            	 				style = "color: burlywood;";
			            	 			}
		            	 		 %>
		            	  				<li class="nav-item"><font size="3"><a style="<%=style%>" class="nav-link active" href=<%=href %>><%=userName %></a></font></li>
		            	  			<%
		            				}
		            			%>
                			</ul>
            			</li>
          			</ul>
				</nav>
				<!-- -----sidebar----- -->
		<main class="col bg-faded py-3">
        	<%
        		String private_token = choosedUser.getPrivateToken();
            	StudentConn sConn = new StudentConn(private_token); 	
            	List<GitlabProject> gitProjects = sConn.getProject();
            	int pro_total_commits = 0;
        		
        	%>
        	<div class="container-fluid" style="margin-top: 20px">
        		<h2><%=choosedUser.getUserName() %></h2>
        		 <div class="card">
	        		 	<div class="card-header">
		        			<h4 id="Statistics Chart"><i class="fa fa-table" aria-hidden="true"></i>&nbsp; 作業</h4>
		        		</div>
		        		<div class="card-block">
			        		<div id="inline">
								<p class="ovol gray" style="padding: 5px 10px; margin-left: 5px;"><fmt:message key="dashboard_p_compileNotYet"/></p>
								<p class="ovol red" style="padding: 5px 10px; margin-left: 5px;"><fmt:message key="dashboard_p_compileFail"/></p>
								<p class="ovol orange" style="padding: 5px 10px; margin-left: 5px;"><fmt:message key="dashboard_p_checkstyleFail"/></p>
								<!-- <p class="ovol green" style="padding: 5px 10px;"><fmt:message key="dashboard_p_plagiarism"/></p>
								<p class="ovol gold" style="padding: 5px 10px;"><fmt:message key="dashboard_p_unitTestFail"/></p> -->
								<p class="ovol blue" style="padding: 5px 10px;"><fmt:message key="dashboard_p_compileSuccess"/></p>
							</div>
	        		 	<table class="table table-striped" style="width: 100%">
			        		<thead>
								<tr>
									<th width="15%">作業</th>
									<%
										for(Project dbProject : dbProjects){
										  %>
										  	<th><%=dbProject.getName() %></th>
										  <%
										}
									%>
								</tr>
							</thead>
							<tbody>
								<tr>
									<th width="15%">Commits</th>
									<%
										for(Project dbProject : dbProjects){
										  
										  int commit_count = 0;
										  JobStatus jobStatus = new JobStatus();
										  String circleColor = null;
										  String projectJenkinsUrl = "";
										  String buildResult = "";
										  
										  for(GitlabProject gitProject : gitProjects){
										    if(dbProject.getName().equals(gitProject.getName())){
											  projectJenkinsUrl = "dashProjectChoosed.jsp?userId=" + choosedUser.getGitLabId() + "&proName=" + gitProject.getName();
										      Dash dash = new Dash(choosedUser);
										      commit_count = dash.getProjectCommitCount(gitProject);
										      String color = dash.getMainTableColor(gitProject);
										      buildResult = color.replace("color ", "");
										    }else{
												continue;
											}
										    circleColor = "circle " + buildResult;
										    %>
										    	<td><p class="<%=circleColor%>"><a href="#" onclick="window.open('<%=projectJenkinsUrl  %>')"><%=commit_count %></a></p></td>
										    <%
										  }
										}
									%>
									
								</tr>
							</tbody>
						</table>
		        	</div>
        		 </div>				
        	</div>
        </main>
      </div>
   </div>
</body>
</html>