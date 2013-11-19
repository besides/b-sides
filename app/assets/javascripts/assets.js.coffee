# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


ready = ->

	$("#s3-uploader").S3Uploader
		progress_bar_target: $('.js-progress-bars')

	$("#s3-uploader").bind "s3_upload_complete", (e, content) ->
		alert("upload complete")


	$('#s3-uploader').bind "s3_upload_failed", (e, content) ->
		alert("#{content.filename} failed to upload : #{content.error_thrown}. Please Try Again")

	true


$(document).ready(ready)
$(document).on('page:load', ready)
