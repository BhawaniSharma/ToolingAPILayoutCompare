# ToolingAPILayoutCompare
This project shows a complete demo of how you can use tooling API to access the page layouts.

Deploy this in your own development environment to see how it works. This supports lightning pretty well.

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

After the successful deployment, please follow the below steps to execute the comparison page:

1. Go to custom settings -> Application Setting.
2. Add the details of target org. This custom setting was created for demo purpose only. We never recommends storing your username and password. Instead, you can use Oauth to connect to target org.
3. After setting up the “Application Settings”, go to all tabs and click on “Compare Layouts”.
4.	In the class, change the endpoint to your target endpoint and create a remote site setting for that.
5. This sample code is currently using “Account Layout” for comparison, however this is open code. You can make the changes in it as needed.
