# AWS Lambda Sample Function
AWS Lambda function to validate OIDC based access mechanism. This Lambda function will be used to create an Authorizer in Amazon API Gateway. Finally, add the Authorizer to the API endpoints that you want to protect.

# Prerequisites 
1. A backend API to protect.
2. Visual Studio 2017 or Visual Studio 2019
3. Download **AWS Toolkit for Visual Studio 2017 and 2019 extension** from Visual Studio Marketplace. To install and configure the toolkit, please follow **https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/getting-set-up.html** document.

# Configuring IdP as an authentication/authorization server
1.	Get the AWS Lambda Code from GitHub using **https://github.com/ThalesGroup/sta-api-access-management/tree/master/API%20Gateway/Amazon%20API%20Gateway**  URL. 

2.	Open the **APIGatewayAuthorizerHandler.sln** file in your Visual Studio.

    Note: This project runs on .NET Core 3.1

3.	In Visual Studio, under **Solution Explorer** > **APIGatewayAuthorizerHandler** project, click **config.json** file.
    ![Lambda_Step3](/Resources/Lambda_Step3.png)
 
4.	In **config.json**, replace <**YOUR IDP WELL KNOWN CONFIGURATION URL**> with your IdP Well Known Configuration URL.

5.	Under **Solution Explorer** > **APIGatewayAuthorizerHandler**, click **Function.cs** file.
    ![Lambda_Step5](/Resources/Lambda_Step5.png)

6.	In **Function.cs**, perform the following steps to configure group-based access rules on the various API endpoints:

    1.  Add your API endpoints and their corresponding HTTP verbs that are publicly accessible without group-based authorization, in the below format:

        policyBuilder.AllowMethod(HttpVerb.<**VERB**>, "<**REST API ENDPOINT**>");

        Here, <**VERB**> can be Get, Post, Put, Patch, Head, Delete, and Options. 

        For example, policyBuilder.AllowMethod(HttpVerb.Get, "/shop");
        ![Lambda_Step6a](/Resources/Lambda_Step6a.png)
   
    2.	To enable group-based authorization for a set of API endpoints, configure the “if” and “else if” conditions with the  required group names. By default, “employee” and “manager” are used as group names.
        ![Lambda_Step6b](/Resources/Lambda_Step6b.png)

    3.	Add your API endpoints and their corresponding HTTP verb that require group authorization, in the below format:

        policyBuilder.AllowMethod(HttpVerb.<**VERB**>, "<**REST API ENDPOINT**>");

        Here, <**VERB**> can be Get, Post, Put, Patch, Head, Delete, and Options.

        For example, policyBuilder.AllowMethod(HttpVerb.Get, " /warehouse ");
        ![Lambda_Step6c](/Resources/Lambda_Step6c.png)
 
7.	To build the **‘APIGatewayAuthorizerHandler’** project, right-click on the ‘**APIGatewayAuthorizerHandler**’ project, and then click **Build**.</br>
	![Lambda_Step7](/Resources/Lambda_Step7.png) 

8.	To publish this project to AWS Lambda, under **Solution Explorer**, right-click on the **‘APIGatewayAuthorizerHandler’** project, and then click **Publish to AWS Lambda**.
	![Lambda_Step8](/Resources/Lambda_Step8.png)

9.	On **Upload to AWS Lambda** window, under **Upload Lambda Function**, perform the following steps:

    1.	In the **Lambda Runtime** field, ensure **.NET Core 3.1** is selected.

    2.	In the **Function Name** field, enter a name for your AWS Lambda function. For example, STALambdaFunction.

    3.	In the **Assembly** field, enter the assembly name of your project. For this project, it would be “APIGatewayAuthorizerHandler”.

    4.	In the **Type** field, enter the value in the “namespace.class” format, of your Handler class. For this project, it would be “APIGatewayAuthorizerHandler.Function”.

    5.	In the **Method** field, ensure that the auto-fill Handler Function name is correct. For this project, it would be “FunctionHandler”.

    6.	In the **Save settings to aws-lambda-tools-defaults.json for future deployments** checkbox, ensure it is checked.

    7.	Click **Next**.
    ![Lambda_Step9](/Resources/Lambda_Step9.png)
 
10.	On **Upload to AWS Lambda** window, under **Advanced Function Details**, perform the following steps:

    1.	Under **Permissions**, in the **Role Name** field, from the drop-down, under the **New Role Based on AWS Managed Policy**, select **AWSLambdaExecute**. Or select an existing role, that has administrator rights.

    2.	Click **Upload**.
    ![Lambda_Step10](/Resources/Lambda_Step10.png)

