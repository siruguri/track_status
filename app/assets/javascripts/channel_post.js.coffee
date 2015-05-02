$(document).ready ->
  article_id = $('#article-id-tag').text().trim()
  api_path = Routes.readability_tag_words_path() + '?id=' + article_id
  $("#tags-list").tokenInput(api_path,
    {hintText: '', insertionPoint: 'after', preventDuplicates: true, selectFirst: false})
  null
