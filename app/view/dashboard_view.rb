require 'osx/cocoa'
require 'html_view'

class DashboardView < HtmlView
  def initialize(webview)
    @web_view = webview
  end
  
  def update
    if $app.default_from_key('hide_welcome_message', '0') == '1'
      hideElement('welcome_message')
    end    
    
    if SpecRunner.command_running?
      setInnerHTML('statistics', "<h3>Just a moment. I'm busy running your examples..</h3>")
    else
      setInnerHTML('dashboard_total_example_count', ExampleFiles.specs_count(:all).to_s)
      setInnerHTML('dashboard_passed_example_count', ExampleFiles.specs_count(:passed).to_s)
      setInnerHTML('dashboard_pending_example_count', ExampleFiles.specs_count(:pending).to_s)
      setInnerHTML('dashboard_failed_example_count', ExampleFiles.specs_count(:failed).to_s)
      
      createExampleList('Failed Examples', 'failed_examples', ExampleFiles.sorted_specs_for_all_files(:filter => :failed))
      createExampleList('Pending Examples', 'pending_examples', ExampleFiles.sorted_specs_for_all_files(:filter => :pending))
      createExampleList('Slowest Examples', 'slowest_examples', ExampleFiles.sorted_specs_for_all_files(:sorted => true), :include_runtime => true)
    end
  end
  
  
  private
  
  def createExampleList(title, id, examples, opts = {})
    return if examples.empty?
    html  = "<h3>#{title}</h3>"
    html << "<ol>"
    css_class = ''
    examples.each do |item|
      css_class = css_class == '' ? 'odd' : ''
      item_text = opts[:include_runtime] ? "#{item} (#{('%0.3f' % item.run_time).to_f} sec.)" : "#{item}"
      html << "<li class='#{css_class}'><a href='#' onclick='alert(\"#{item.id}@spec_view\")'>#{item_text}</a></li>"
    end    
    html << "</ol>"
    setInnerHTML(id, html)
  end
end