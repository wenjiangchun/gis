<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">
<head>
	<title><sitemesh:write property='title' /></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
	<link rel="stylesheet" href="${ctx}/resources/style/style.css" />
	<link rel="stylesheet" href="${ctx}/resources/font-awesome/css/font-awesome.css" />
	<script type="text/javascript" src="${ctx}/resources/jquery/jquery.min.js"></script>
	<script type="text/javascript" src="${ctx}/resources/echarts/echarts.min.js"></script>
	<sitemesh:write property='head' />
</head>

<body class="no-skin">
<!-- #section:basics/navbar.layout -->
<div class="bg_box">
	<div class="logo_box">
		<img src="${ctx}/resources/style/images/logo.png">
	</div>
<%@ include file="/WEB-INF/layouts/header.jsp"%>
<!-- /section:basics/navbar.layout -->
<div class="main-container" id="main-container">
	<!-- #section:basics/sidebar -->
	<!-- /section:basics/sidebar -->
	<div class="main-content">
		<div class="main-content-inner">
			<!-- #section:basics/content.breadcrumbs -->
			<sitemesh:write property='body' />
			<!-- /section:basics/content.breadcrumbs -->
		</div>
	</div><!-- /.main-content -->
	<%@ include file="/WEB-INF/layouts/footer.jsp"%>
</div><!-- /.main-container -->
</div>
</body>
</html>
