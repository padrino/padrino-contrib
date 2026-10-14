require 'spec_helper'

begin
  require 'active_record'
  require 'sqlite3'
rescue LoadError
end

if defined?(ActiveRecord::Base) && defined?(SQLite3)
  require 'padrino-contrib/orm/active_record/permalink'
  require 'padrino-contrib/orm/active_record/permalink_i18n'

  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define do
    create_table(:articles) { |t| t.string :type; t.string :title; t.string :permalink }
    create_table(:notes)    { |t| t.string :name; t.string :permalink }
    create_table(:pages)    { |t| t.string :type; t.string :title_en; t.string :title_de; t.string :permalink_en; t.string :permalink_de }
    create_table(:posts)    { |t| t.string :name_en; t.string :permalink_en }
  end

  module ActiveRecordSpec
    class Article < ActiveRecord::Base; has_permalink :title; end
    class NewsArticle < Article; end
    class Note < ActiveRecord::Base; has_permalink :name; end

    class Page < ActiveRecord::Base; has_i18n_permalink :title, :langs => [:en, :de]; end
    class SpecialPage < Page; end
    class Post < ActiveRecord::Base; has_i18n_permalink :name, :langs => [:en]; end
  end

  describe 'ActiveRecord extensions' do
    describe 'has_permalink' do
      it 'generates a permalink for the model' do
        expect(ActiveRecordSpec::Article.create!(:title => 'Hello World!').permalink).to eq 'hello-world'
      end

      it 'generates a permalink for a subclass of the model' do
        article = ActiveRecordSpec::NewsArticle.create!(:title => 'Breaking News')
        expect(article.permalink).to eq 'breaking-news'
        expect(ActiveRecordSpec::Article.find(article.id)).to be_a ActiveRecordSpec::NewsArticle
      end

      it 'keeps the field of each model' do
        note = ActiveRecordSpec::Note.create!(:name => 'Side Note')
        article = ActiveRecordSpec::Article.create!(:title => 'Main Story')
        expect(note.permalink).to eq 'side-note'
        expect(article.permalink).to eq 'main-story'
      end
    end

    describe 'has_i18n_permalink' do
      it 'generates a permalink for each language' do
        page = ActiveRecordSpec::Page.create!(:title_en => 'Hello World', :title_de => 'Grüße aus Köln')
        expect([page.permalink_en, page.permalink_de]).to eq ['hello-world', 'grusse-aus-koln']
      end

      it 'generates permalinks for a subclass of the model' do
        page = ActiveRecordSpec::SpecialPage.create!(:title_en => 'Special Offer', :title_de => 'Sonderangebot')
        expect([page.permalink_en, page.permalink_de]).to eq ['special-offer', 'sonderangebot']
      end

      it 'keeps the field and languages of each model' do
        post = ActiveRecordSpec::Post.create!(:name_en => 'Second Model')
        page = ActiveRecordSpec::Page.create!(:title_en => 'First Model', :title_de => 'Erstes Modell')
        expect(post.permalink_en).to eq 'second-model'
        expect([page.permalink_en, page.permalink_de]).to eq ['first-model', 'erstes-modell']
        expect(ActiveRecordSpec::Post.i18n_permalink_langs).to eq [:en]
        expect(ActiveRecordSpec::SpecialPage.i18n_permalink_langs).to eq [:en, :de]
      end
    end
  end
else
  describe 'ActiveRecord extensions' do
    it 'are checked when ActiveRecord and sqlite3 are installed (ACTIVERECORD=1)' do
      skip 'ActiveRecord or sqlite3 is not available'
    end
  end
end
