package fcu.selab.progedu.conn;

import java.util.List;

import org.gitlab.api.models.GitlabProject;
import org.json.JSONObject;

import fcu.selab.progedu.config.JenkinsConfig;
import fcu.selab.progedu.data.Project;
import fcu.selab.progedu.data.User;
import fcu.selab.progedu.db.ProjectDbManager;
import fcu.selab.progedu.exception.LoadConfigFailureException;
import fcu.selab.progedu.jenkins.JenkinsApi;
import fcu.selab.progedu.jenkins.JobStatus;

public class Dash {
  User user;
  ProjectDbManager pdb = ProjectDbManager.getInstance();
  List<Project> dbProjects = pdb.listAllProjects();
  List<GitlabProject> gitProjects;
  JenkinsConfig jenkinsData = JenkinsConfig.getInstance();
  JenkinsApi jenkins = JenkinsApi.getInstance();
  JobStatus jobStatus = new JobStatus();

  public Dash(User user) {
    this.user = user;
  }

  /**
   * get project build result
   * 
   * @param gitProject
   *          student project
   * @return color
   */
  public String getMainTableColor(GitlabProject gitProject) {

    // ---Jenkins---
    String jobName = user.getUserName() + "_" + gitProject.getName();
    jobStatus.setName(jobName);
    String jobUrl = "";
    try {
      jobUrl = jenkinsData.getJenkinsHostUrl() + "/job/" + jobName;
    } catch (LoadConfigFailureException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    jobStatus.setUrl(jobUrl + "/api/json");

    // Get job status
    jobStatus.setJobApiJson();
    String apiJson = jobStatus.getJobApiJson();
    boolean isMaven = jenkins.checkProjectIsMvn(apiJson);
    int commitCount = jenkins.getJobBuildCommit(apiJson);

    String color = null;
    int checkstyleErrorAmount = 0;
    if (null != apiJson) {
      color = jenkins.getJobJsonColor(apiJson);
      if (isMaven) {
        if (color.equals("red")) {
          JSONObject checkstyleDes = jenkins.getCheckstyleDes(apiJson);
          checkstyleErrorAmount = jenkins.getCheckstyleErrorAmount(checkstyleDes);
          if (checkstyleErrorAmount != 0) {
            color = "orange";
          }
        }
      }
    }

    String circleColor = "";
    if (commitCount == 1) {
      circleColor = "circle gray";
    } else {
      if (color != null) {
        circleColor = "circle " + color;
      } else {
        circleColor = "circle gray";
      }
    }
    return circleColor;
  }

  /**
   * get project commit count
   * 
   * @param gitProject
   *          student project
   * @return commit count
   */
  public int getProjectCommitCount(GitlabProject gitProject) {
    // ---Jenkins---
    String jobName = user.getUserName() + "_" + gitProject.getName();
    jobStatus.setName(jobName);
    String jobUrl = "";
    try {
      jobUrl = jenkinsData.getJenkinsHostUrl() + "/job/" + jobName;
    } catch (LoadConfigFailureException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    jobStatus.setUrl(jobUrl + "/api/json");

    // Get job status
    jobStatus.setJobApiJson();
    String apiJson = jobStatus.getJobApiJson();
    int commitCount = jenkins.getJobBuildCommit(apiJson);
    return commitCount;
  }

}