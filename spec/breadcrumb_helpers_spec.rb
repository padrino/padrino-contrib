require 'spec_helper'

describe "BreadcrumbHelpers" do
  include Padrino::Helpers::OutputHelpers
  include Padrino::Helpers::TagHelpers
  include Padrino::Helpers::AssetTagHelpers
  include Padrino::Contrib::Helpers::Breadcrumbs

  let(:breadcrumb){ Padrino::Helpers::Breadcrumb.new }
  after(:each) { breadcrumb.reset! }

  describe "for Breadcrumbs#breadcrumbs method" do
    it 'should support breadcrumbs which is Padrino::Helpers::Breadcrumbs instance.' do
      breadcrumb.add "foo", "/foo", "foo link"
      expect(breadcrumbs(breadcrumb)).to have_selector(:a, :content => "Foo link", :href => "/foo")
    end

    it 'should support bootstrap' do
      breadcrumb.add "foo", "/foo", "foo link"
      expect(breadcrumbs(breadcrumb, true)).to have_selector(:span, :content => "/", :class => "divider")
    end

    it 'should support active' do
      breadcrumb.add "foo", "/foo", "foo link"
      expect(breadcrumbs(breadcrumb, nil, "custom-active")).to have_selector(:li, :class => "custom-active")
    end

    it 'should support options' do
      actual_html = breadcrumbs(breadcrumb, nil, nil, :id => "breadcrumbs-id", :class => "breadcrumbs-class")
      expect(actual_html).to have_selector(:ul, :class => "breadcrumbs-class breadcrumb", :id => "breadcrumbs-id")
    end
  end

  describe "for #add method" do
    it 'should support name of string and symbol type' do
      breadcrumb.add "foo", "/foo", "Foo Link"
      breadcrumb.add :bar, "/bar", "Bar Link"

      actual_html = breadcrumbs(breadcrumb)
      expect(actual_html).to have_selector(:a, :content => "Foo link", :href => "/foo")
      expect(actual_html).to have_selector(:a, :content => "Bar link", :href => "/bar")
    end

    it 'should support url' do
      breadcrumb.add :foo, "/foo", "Foo Link"
      expect(breadcrumbs(breadcrumb)).to have_selector(:a, :href => "/foo")
    end

    it 'should support caption' do
      breadcrumb.add :foo, "/foo", "Foo Link"
      expect(breadcrumbs(breadcrumb)).to have_selector(:a, :content => "Foo link")
    end

    it 'should support options' do
      breadcrumb.add :foo, "/foo", "Foo Link", :id => "foo-id", :class => "foo-class"
      breadcrumb.add :bar, "/bar", "Bar Link", :id => "bar-id", :class => "bar-class"

      actual_html = breadcrumbs(breadcrumb)
      expect(actual_html).to have_selector(:li, :class => "foo-class", :id => "foo-id")
      expect(actual_html).to have_selector(:li, :class => "bar-class active", :id => "bar-id")
    end
  end

  describe "for #del method" do
    it 'should support name of string type' do
      breadcrumb.add "foo", "/foo", "Foo Link"
      breadcrumb.add :bar, "/bar", "Bar Link"

      breadcrumb.del "foo"
      breadcrumb.del "bar"

      actual_html = breadcrumbs(breadcrumb)
      expect(actual_html).not_to have_selector(:a, :content => "Foo link", :href => "/foo")
      expect(actual_html).not_to have_selector(:a, :content => "Bar link", :href => "/bar")
    end

    it 'should support name of symbol type' do
      breadcrumb.add "foo", "/foo", "Foo Link"
      breadcrumb.add :bar, "/bar", "Bar Link"

      breadcrumb.del :foo
      breadcrumb.del :bar

      actual_html = breadcrumbs(breadcrumb)
      expect(actual_html).not_to have_selector(:a, :content => "Foo link", :href => "/foo")
      expect(actual_html).not_to have_selector(:a, :content => "Bar link", :href => "/bar")
    end
  end

  describe "for #set_home method" do
    it 'should modified home item elements.' do
      breadcrumb.set_home("/custom", "Custom Home Page")
      expect(breadcrumbs(breadcrumb)).to have_selector(:a, :content => "Custom home page", :href => "/custom")
    end

    it 'should support options' do
      breadcrumb.set_home("/custom", "Custom Home Page", :id => "home-id")

      actual_html = breadcrumbs(breadcrumb)
      expect(actual_html).to have_selector(:li, :id => "home-id")
      expect(actual_html).to have_selector(:a, :content => "Custom home page", :href => "/custom")
    end
  end

  describe "for #reset method" do
    it 'should be #items which contains only home item.' do
      breadcrumb.set_home("/custom", "Custom Home Page")
      breadcrumb.add "foo", "/foo", "Foo Link"
      breadcrumb.add :bar, "/bar", "Bar Link"

      breadcrumb.reset

      actual_html = breadcrumbs(breadcrumb)
      expect(actual_html).to have_selector(:a, :content => "Custom home page", :href => "/custom")
      expect(actual_html).not_to have_selector(:a, :content => "Foo link", :href => "/foo")
      expect(actual_html).not_to have_selector(:a, :content => "Bar link", :href => "/bar")
    end
  end

  describe "for #reset! method" do
    it 'should be #items which contains only default home item.' do
      breadcrumb.add "foo", "/foo", "foo link"
      breadcrumb.add :bar, "/bar", "Bar Link"

      breadcrumb.reset!

      actual_html = breadcrumbs(breadcrumb)
      expect(actual_html).to have_selector(:a, :content => "Home Page", :href => "/")
      expect(actual_html).not_to have_selector(:a, :content => "Foo link", :href => "/foo")
      expect(actual_html).not_to have_selector(:a, :content => "Bar link", :href => "/bar")
    end
  end
end
