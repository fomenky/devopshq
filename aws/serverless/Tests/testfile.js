
const AWS = require('aws-sdk')
const { sendResponse, validateInput } = require("../functions");
const AmazonCognitoIdentity = require('amazon-cognito-identity-js');
const ses = new AWS.SES();
var nodemailer = require('nodemailer');

module.exports.handler =  async (event) => {

	var mailOptions = {
		from: 'support@mickmaq.com',
		subject: 'Seller Request Acceptance',
		html: '<p>Hello '+'Seller'+',</p>'+
		 '<br/>'+
		 '<p>Congratulations! Welcome to the MICKmaq family!<p>' +
		 '<br/>'+
		 '<p>You have successfully completed the registration to be a verified seller.</p>'+
		 '<br/>'+
		 "<p>We're excited to get you started. Please use your email to access your account and take control of your income.</p>"+
		 '<br/>'+
		 '<p>As a new seller, we want to share with you:</p>'+
		 '<br/>'+
		 '<p>Seller Terms and Agreements to navigate selling on the app Our FAQ to answer any questions you may have Our support team - info@mickmaq.com - for those tricky questions you may have.</p>'+
		 '<br/>'+
		 '<p>Best of luck on your earnings!</p>'+
		 '<br/>'+
		 '<p>Regards,</p>'+
		 '<p>Team MICKmaq.</p>',
		to: 'sellershubham@yopmail.com'
	};

   
	// create Nodemailer SES transporter
	var transporter = nodemailer.createTransport({
		SES: ses
	});

	 // send email
	const mailResponse = await transporter.sendMail(mailOptions);


}