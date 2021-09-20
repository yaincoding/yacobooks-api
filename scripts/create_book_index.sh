#!/usr/bin/bash

#ELASTICSEARCH_HOST="http://ec2-13-209-181-246.ap-northeast-2.compute.amazonaws.com:9200/book?pretty"
ELASTICSEARCH_HOST="http://localhost:9200/book?pretty"

curl -XPUT  $ELASTICSEARCH_HOST \
-u "${ES_USER}:${ES_PASSWORD}" \
-H "Content-Type: application/json" \
-d \
'{
  "settings": {
    "number_of_shards": 5,
    "number_of_replicas": 1,
    "index.max_ngram_diff": 50,
    "analysis": {
      "char_filter": {
        "white_remove_char_filter": {
          "type": "pattern_replace",
          "pattern": "\\s+",
          "replacement": ""
        },
        "special_character_filter": {
          "pattern": "[^\\p{L}\\p{Nd}\\p{Blank}]",
          "type": "pattern_replace",
          "replacement": ""
        },
        "author_trivial_filter": {
          "type": "mapping",
          "mappings": [
            "edited by => ",
            "지음 => ",
            "옮김 => ",
            "지은이 => ",
            "일러스트 => ",
            "editors => ",
            "이 책을 쓰신 분 => ",
            "글쓴이 => ",
            "만화 => ",
            "번역 => ",
            "글 => ",
            "그림: => ",
            "저자 => ",
            "엮은이 => ",
            "편저자 => ",
            "구성: => ",
            "연구책임자 => ",
            "연구자 => ",
            "디자인 => ",
            "편집 => ",
            "편저 => "
          ]
        }
      },
      "filter": {
        "ngram_filter": {
          "type": "ngram",
          "min_gram": 3,
          "max_gram": 50
        },
        "author_ngram_filter": {
          "type": "ngram",
          "min_gram": 2,
          "max_gram": 10
        }
      },
      "analyzer": {
        "jamo_analyzer": {
          "type": "custom",
          "tokenizer": "keyword",
          "filter": [
            "hanhinsam_jamo"
          ]
        },
        "title_full_analyzer": {
          "type": "custom",
          "char_filter": [
            "white_remove_char_filter",
            "special_character_filter"
          ],
          "tokenizer": "keyword",
          "filter": [
            "lowercase",
            "hanhinsam_jamo"
          ]
        },
        "title_term_analyzer": {
          "type": "custom",
          "char_filter": [
            "special_character_filter"
          ],
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "hanhinsam_jamo",
            "ngram_filter"
          ]
        },
        "ac_analyzer": {
          "type": "custom",
          "char_filter": [
            "white_remove_char_filter"
          ],
          "tokenizer": "keyword",
          "filter": [
            "lowercase",
            "hanhinsam_jamo",
            "ngram_filter"
          ]
        },
        "chosung_analyzer": {
          "type": "custom",
          "char_filter": [
            "white_remove_char_filter",
            "special_character_filter"
          ],
          "tokenizer": "keyword",
          "filter": [
            "lowercase",
            "hanhinsam_chosung"
          ]
        },
        "hantoeng_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "char_filter": [
            "special_character_filter"
          ],
          "filter": [
            "lowercase",
            "hanhinsam_hantoeng"
          ]
        },
        "engtohan_analyzer": {
          "type": "custom",
          "char_filter": [
            "special_character_filter"
          ],
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "hanhinsam_engtohan"
          ]
        },
        "author_index_analyzer": {
          "type": "custom",
          "char_filter": [
            "author_trivial_filter",
            "special_character_filter",
            "white_remove_char_filter"
          ],
          "tokenizer": "keyword",
          "filter": [
            "author_ngram_filter"
          ]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "isbn13": {
        "type": "keyword"
      },
      "title": {
        "type": "keyword",
        "copy_to": ["title_full", "title_term", "title_ac", "title_chosung", "title_engtohan", "title_hantoeng"]
      },
      "title_full": {
        "type": "text",
        "analyzer": "title_full_analyzer"
      },
      "title_term": {
        "type": "text",
        "analyzer": "title_term_analyzer"
      },
      "title_ac": {
        "type": "text",
        "analyzer": "ac_analyzer"
      },
      "title_chosung": {
        "type": "text",
        "analyzer": "chosung_analyzer"
      },
      "title_engtohan": {
        "type": "text",
        "analyzer": "standard", 
        "search_analyzer": "engtohan_analyzer"
      },
      "title_hantoeng": {
        "type": "text",
        "analyzer": "standard", 
        "search_analyzer": "hantoeng_analyzer"
      },
      "author": {
        "type": "keyword",
        "copy_to": ["author_text"]
      },
      "author_text": {
        "type": "text",
        "analyzer": "author_index_analyzer",
        "search_analyzer": "standard"
      },
      "publichser": {
        "type": "keyword"
      },
      "pubDate": {
        "type": "keyword"
      },
      "imageUrl": {
        "type": "keyword"
      },
      "description": {
        "type": "keyword"
      }
    }
  } 
}'