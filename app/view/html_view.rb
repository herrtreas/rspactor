class HtmlView
  attr_accessor :web_view
  
  def document
    @web_view.mainFrame.DOMDocument
  end
  
  def getElementById(element_id)
    document.getElementById(element_id)
  end
  
  def h(raw_text)
    return '' unless raw_text
    raw_text.gsub!('<', '&lt;')
    raw_text.gsub!('>', '&gt;')
    raw_text
  end
  
  def setInnerHTML(element_id, html)
    element = getElementById(element_id)
    element.setInnerHTML(html)
  end

  def setInnerText(element_id, text)
    element = getElementById(element_id)
    element.setInnerText(text)
  end
  
  def hideElement(element_id)
    element = getElementById(element_id)
    element.className = 'hidden'    
  end
end