$(document).ready ->
	article_id = $('#article-id-tag').text().trim()
	$("#tags-list").tokenInput('/readability/tag_words?id=' + article_id, 
    {hintText: '', insertionPoint: 'after', preventDuplicates: true})
	null
