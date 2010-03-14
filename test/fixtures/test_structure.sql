CREATE TABLE IF NOT EXISTS `widgets` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `content` text,
  `unindexed_content` text,
  `active` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `fulltext_rows` (
  `id` int(11) NOT NULL auto_increment,
  `fulltextable_type` varchar(50) NOT NULL,
  `fulltextable_id` int(11) NOT NULL,
  `value` text NOT NULL,
  `parent_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_fulltext_rows_on_fulltextable_type_and_fulltextable_id` (`fulltextable_type`,`fulltextable_id`),
  KEY `index_fulltext_rows_on_parent_id` (`parent_id`),
  FULLTEXT KEY `fulltext_index` (`value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
