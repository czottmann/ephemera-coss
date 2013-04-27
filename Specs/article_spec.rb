require "#{ENV['SRCROOT']}/Specs/spec_helper"

require "article"

module Instapaper
    
    describe Article do
        a = Article.new(12,"Article Title")
        a.fetch()
    
        file = File.join(File.dirname(__FILE__), "fixtures/", "article-data-1.html")
        data = File.read(file)
    
        e = Pointer.new_with_type("@")
        doc = NSXMLDocument.alloc.initWithXMLString(data, options: NSXMLDocumentTidyHTML, error: e)
        a.html = a.process_raw (doc, e)
    
        a.title.should == "Why Sleep Deprivation Eases Depression: Scientific American"
        a.site.should == "Scientific American"
        a.html.should_not == nil
        a.html.should_not == ""


        file = File.join(File.dirname(__FILE__), "fixtures/", "article-data-2.html")
        data = File.read(file)
        
        e = Pointer.new_with_type("@")
        doc = NSXMLDocument.alloc.initWithXMLString(data, options: NSXMLDocumentTidyHTML, error: e)
        a.html = a.process_raw (doc, e)
        
        a.title.should == "Reading Other People's Code"
        a.site.should == "mahdiyusuf.com"
        a.html.should_not == nil
        a.html.should_not == ""

    end
end