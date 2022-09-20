/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2022.1.4 20:37:58                            */
/*==============================================================*/


drop table if exists GamesInfo;

drop table if exists User;

drop table if exists record;

/*==============================================================*/
/* Table: GamesInfo                                             */
/*==============================================================*/
create table GamesInfo
(
   GameID               numeric(20,0) not null,
   WinnerID             numeric(10,0),
   WinnerMoney          numeric(8,2),
   GameTime             timestamp,
   primary key (GameID)
);

/*==============================================================*/
/* Table: User                                                  */
/*==============================================================*/
create table User
(
   UserID               numeric(10,0) not null,
   UserName             varchar(20),
   Password             varchar(0),
   RemainMoney          float(8,2),
   BetMoney             float(8,2),
   WinningRate          float,
   primary key (UserID)
);

/*==============================================================*/
/* Table: record                                                */
/*==============================================================*/
create table record
(
   UserID               numeric(10,0) not null,
   GameID               numeric(20,0) not null,
   ActionTime2          timestamp not null,
   CurrentID2           numeric(10,0) not null,
   CurrentOut           int,
   ActionType           int,
   primary key (UserID, GameID, ActionTime2, CurrentID2)
);

alter table record add constraint FK_play foreign key (UserID)
      references User (UserID) on delete restrict on update restrict;

alter table record add constraint FK_recording foreign key (GameID)
      references GamesInfo (GameID) on delete restrict on update restrict;

