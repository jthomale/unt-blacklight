# frozen_string_literal: true
class CatalogController < ApplicationController

  include Blacklight::Catalog
  include Blacklight::Marc::Catalog

  def search_action_url options = {}
    options[:protocol] = request.headers['X-Forwarded-Proto'] or request.protocol
    super options
  end

  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      qt: 'catalog-search',
      rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'catalog-search'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1,
    #  # q: '{!term f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title'
    config.index.display_type_field = 'material_type'

    # solr field configuration for document/show views
    config.show.title_field = 'main_title'
    config.show.display_type_field = 'material_type'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'material_type', label: 'Format', :query => {
        :archival_collections => { label: 'Archival Collections', fq: "material_type:p" },
        :books => { label: 'Books (All)', fq: "material_type:a OR material_type:i OR material_type:n" },
        :books_audio => { label: 'Books (Audio)', fq: "material_type:i" },
        :books_electronic => { label: 'Books (Electronic)', fq: "material_type:n" },
        :books_print => { label: 'Books (Print)', fq: "material_type:a" },
        :computer_files => { label: 'Computer Files', fq: "material_type:m" },
        :databases => { label: 'Databases', fq: "material_type:b" },
        :educational_kits => { label: 'Educational Kits', fq: "material_type:o" },
        :journals => { label: 'Journals (All)', fq: "material_type:q OR material_type:y" },
        :journals_online => { label: 'Journals (Online)', fq: "material_type:q" },
        :journals_print => { label: 'Journals (Print)', fq: "material_type:y" },
        :manuscripts => { label: 'Manuscripts', fq: "material_type:t" },
        :maps => { label: 'Maps', fq: "material_type:e OR material_type:f" },
        :music_cds => { label: 'Music (CDs)', fq: "material_type:j" },
        :music_scores => { label: 'Music (Scores)', fq: "material_type:c OR material_type:d OR material_type:s" },
        :physical_objects => { label: 'Physical Objects', fq: "material_type:r" },
        :print_graphics => { label: 'Print Graphics', fq: "material_type:k" },
        :theses_and_dissertations => { label: 'Theses and Dissertations', fq: "material_type:z OR material_type:s" },
        :video => { label: 'Video (DVD, VHS, Film)', fq: "material_type:g" },
    }
    config.add_facet_field 'publication_dates_facet', label: 'Publication Date', :query => {
        :years_21st_cent => { label: '21st Century', fq: "publication_dates_facet:[2000 TO 2099] OR publication_dates_facet:\"21st century\"" },
        :years_highest => { label: '2015 or later', fq: "publication_dates_facet:[2015 TO 2099]" },
        :years_2010_2014 => { label: '2010 to 2014', fq: "publication_dates_facet:[2010 TO 2014]" },
        :years_2000_2009 => { label: '2000 to 2009', fq: "publication_dates_facet:[2000 TO 2009]" },
        :years_20th_cent => { label: '20th Century', fq: "publication_dates_facet:[1900 TO 1999] OR publication_dates_facet:\"20th century\"" },
        :years_1990_1999 => { label: '1990 to 1999', fq: "publication_dates_facet:[1990 TO 1999]" },
        :years_1980_1989 => { label: '1980 to 1989', fq: "publication_dates_facet:[1980 TO 1989]" },
        :years_1970_1979 => { label: '1970 to 1979', fq: "publication_dates_facet:[1970 TO 1979]" },
        :years_1960_1969 => { label: '1960 to 1969', fq: "publication_dates_facet:[1960 TO 1969]" },
        :years_1950_1959 => { label: '1950 to 1959', fq: "publication_dates_facet:[1950 TO 1959]" },
        :years_1940_1949 => { label: '1940 to 1949', fq: "publication_dates_facet:[1940 TO 1949]" },
        :years_1900_1939 => { label: '1900 to 1939', fq: "publication_dates_facet:[1900 TO 1939]" },
        :years_19th_cent => { label: '19th Century', fq: "publication_dates_facet:[1800 TO 1899] OR publication_dates_facet:\"19th century\"" },
        :years_1850_1899 => { label: '1850 to 1899', fq: "publication_dates_facet:[1850 TO 1899]" },
        :years_1800_1849 => { label: '1800 to 1849', fq: "publication_dates_facet:[1800 TO 1849]" },
        :years_18th_cent => { label: '18th Century', fq: "publication_dates_facet:[1700 TO 1799] OR publication_dates_facet:\"18th century\"" },
        :years_1750_1799 => { label: '1750 to 1799', fq: "publication_dates_facet:[1750 TO 1799]" },
        :years_1700_1749 => { label: '1700 to 1749', fq: "publication_dates_facet:[1700 TO 1749]" },
        :years_17th_cent => { label: '17th Century', fq: "publication_dates_facet:[1600 TO 1699] OR publication_dates_facet:\"17th century\"" },
        :years_1650_1699 => { label: '1650 to 1699', fq: "publication_dates_facet:[1650 TO 1699]" },
        :years_1600_1649 => { label: '1600 to 1649', fq: "publication_dates_facet:[1600 TO 1649]" },
        :years_16th_cent => { label: '16th Century', fq: "publication_dates_facet:[1500 TO 1599] OR publication_dates_facet:\"16th century\"" },
        :years_15th_cent => { label: '15th Century', fq: "publication_dates_facet:[1400 TO 1499] OR publication_dates_facet:\"15th century\"" },
        :years_14th_cent => { label: '14th Century', fq: "publication_dates_facet:[1300 TO 1399] OR publication_dates_facet:\"14th century\"" },
        :years_13th_cent => { label: '13th Century', fq: "publication_dates_facet:[1200 TO 1299] OR publication_dates_facet:\"13th century\"" },
        :years_12th_cent => { label: '12th Century', fq: "publication_dates_facet:[1100 TO 1199] OR publication_dates_facet:\"12th century\"" },
        :years_11th_cent => { label: '11th Century', fq: "publication_dates_facet:[1000 TO 1099] OR publication_dates_facet:\"11th century\"" },
        :years_10th_cent => { label: '10th Century', fq: "publication_dates_facet:[900 TO 999] OR publication_dates_facet:\"10th century\"" },
        :years_lowest => { label: 'Pre-10th Century', fq: "publication_dates_facet:/..?.?/ AND publication_dates_facet:[0 TO 899]" },
    }
    # config.add_facet_field 'publication_dates_facet', label: 'Year of Publication'
    config.add_facet_field 'public_author_facet', label: 'Author or Contributor', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'public_title_facet', label: 'Work Title', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'public_series_facet', label: 'Series Title', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'meetings_facet', label: 'Meeting or Event', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'public_genre_facet', label: 'Genre', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'public_subject_facet', label: 'Subject', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'languages', label: 'Language', limit: 20
    config.add_facet_field 'geographic_terms_facet', label: 'Region', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'era_terms_facet', label: 'Era', limit: 20, index_range: 'A'..'Z'

    # config.add_facet_field 'example_pivot_field', label: 'Pivot Field', :pivot => ['material_type', 'languages']

    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #    :years_5 => { label: 'within 5 Years', fq: "publication_dates:[#{Time.zone.now.year - 5 } TO *]" },
    #    :years_10 => { label: 'within 10 Years', fq: "publication_dates:[#{Time.zone.now.year - 10 } TO *]" },
    #    :years_25 => { label: 'within 25 Years', fq: "publication_dates:[#{Time.zone.now.year - 25 } TO *]" }
    # }

    config.add_facet_field 'game_duration_facet_field', label: 'Games, Duration', :query => {
        :duration_1 => { label: 'less than 30 minutes', fq: "game_facet:d1t29" },
        :duration_30 => { label: '30 minutes to 1 hour', fq: "game_facet:d30t59" },
        :duration_60 => { label: '1 to 2 hours', fq: "game_facet:d60t120" },
        :duration_120 => { label: 'more than 2 hours', fq: "game_facet:d120t500" }
    }
    config.add_facet_field 'game_players_facet_field', label: 'Games, Number of Players', :query => {
        :players_1 => { label: '1 player', fq: "game_facet:p1" },
        :players_2 => { label: '2 to 4 players', fq: "game_facet:p2t4" },
        :players_4 => { label: '5 to 8 players', fq: "game_facet:p4t8" },
        :players_8 => { label: 'more than 8 players', fq: "game_facet:p9t99" }
    }
    config.add_facet_field 'game_age_facet_field', label: 'Games, Recommended Age', :query => {
        :age_1 => { label: '1 to 4 years', fq: "game_facet:a1t4" },
        :age_5 => { label: '5 to 9 years', fq: "game_facet:a5t9" },
        :age_10 => { label: '10 to 13 years', fq: "game_facet:a10t13" },
        :age_14 => { label: '14 to 16 years', fq: "game_facet:a14t16" },
        :age_17 => { label: '17 years and up', fq: "game_facet:a17t100" }
    }


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'full_title', label: 'Title'
    config.add_index_field 'creator', label: 'Author/Creator'
    config.add_index_field 'contributors', label: 'Contributors'
    # config.add_index_field 'material_type', label: 'Material Type'
    config.add_index_field 'languages', label: 'Languages'
    config.add_index_field 'publishers', label: 'Publisher'
    config.add_index_field 'publication_places', label: 'Publication Place'
    config.add_index_field 'publication_dates', label: 'Publication Date'
    config.add_index_field 'main_call_number', label: 'Call number'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'full_title', label: 'Title'
    config.add_show_field 'creator', label: 'Author/Creator'
    config.add_show_field 'contributors', label: 'Contributors'
    # config.add_show_field 'material_type', label: 'Material Type'
    config.add_show_field 'urls', label: 'URLs'
    # config.add_show_field 'url_suppl_display', label: 'More Information'
    config.add_show_field 'languages', label: 'Languages'
    config.add_show_field 'publishers', label: 'Publisher'
    config.add_show_field 'publication_places', label: 'Publication Place'
    config.add_show_field 'publication_dates', label: 'Publication Date'
    config.add_show_field 'main_call_number', label: 'Call number'
    config.add_show_field 'isbn_numbers', label: 'ISBN'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'text', label: 'All Fields'


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        qf: '$title_qf',
        pf: '$title_pf'
      }
    end

    config.add_search_field('Author/Creator') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'creator' }
      field.solr_local_parameters = {
        qf: '$creator_qf',
        pf: '$creator_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'catalog-search'
      field.solr_local_parameters = {
        qf: '$subject_qf',
        pf: '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_sort asc', label: 'relevance'
    # config.add_sort_field 'publication_dates desc, title_sort asc', label: 'publication date'
    config.add_sort_field 'creator_sort asc, title_sort asc', label: 'creator'
    config.add_sort_field 'title_sort asc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end
end
