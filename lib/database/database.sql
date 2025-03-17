use fpt_jp;

create table if not exists kanji_word (
  id            int primary key auto_increment,
  lesson_num    int           not null,
  word          nvarchar(50)  not null,
  pronunciation nvarchar(50)  not null,
  sino_viet     nvarchar(100) not null default '',
  meaning       nvarchar(255) not null
);

create table if not exists vocab (
  id      int primary key,
  word    nvarchar(20)  not null,
  meaning nvarchar(255) not null
);

create table if not exists vocab_extra (
  id       int primary key,
  vocab_id int           not null,
  content  nvarchar(50)  not null,
  meaning  nvarchar(255) not null,
  foreign key (vocab_id) references vocab (id)
);

create table if not exists vocab_particle (
  id       int primary key,
  vocab_id int           not null,
  `usage`  nvarchar(255) not null,
  foreign key (vocab_id) references vocab (id)
);
