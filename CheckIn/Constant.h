//
//  Constant.h
//  CheckIn
//
//  Created by heliumsoft on 9/5/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#ifndef CheckIn_Constant_h
#define CheckIn_Constant_h

#define APP ((AppDelegate *)[UIApplication sharedApplication].delegate)
// QuickBase inforamtion

#define APP_DOMAIN @"unlimitedcompanies.quickbase.com"
#define APP_BASE_URL  @"https://unlimitedcompanies.quickbase.com/up"

//#define APP_TOKEN @"cg72wc4c9pbumidqkhgaibkcgh3v"
//#define APP_DB_ID @"bj2d8q5yu"

#define APP_TOKEN @"cg72wc4c9pbumidqkhgaibkcgh3v"
#define APP_DB_ID @"bkcat5gfb"

// Authentication

#define NO_ERROR_KEY @"errtext"
#define NO_ERROR @"No error"

#define TICKET_KEY @"ticket"
#define USERID_KEY @"userid"


#define ROLE_TYPE_ADMIN @"Administrator"
#define ROLE_TYPE_PROJECT_MANAGER @"Project Manager"
#define ROLE_TYPE_Super @"Superintendant"
#define ROLE_TYPE_MANAGEMENT @"Management"
#define ROLE_TYPE_PRODUCTION_MANAGER @"Production Manager"
#define ROLE_TYPE_SERVICE_MANAGER @"Service Manager"

// Table IDs

//#define TABLE_PROJECTS_DB_ID @"bj2d8q53b"
//#define TABLE_WORKERS_DB_ID @"bj2d8q645"
//#define TABLE_REPORT_DB_ID @"bj2d8q6by"
//#define TABLE_TIMESHEET_DB_ID @"bj2d8q6c3"
//#define TABLE_CLOCK_IN_DB_ID @"bj9fn2fjh"


#define TABLE_PROJECTS_DB_ID @"bkcat5ghs"
#define TABLE_WORKERS_DB_ID @"bkcat5h8g"
#define TABLE_TIMESHEET_DB_ID @"bkcat5gxe"


// Field IDS

#define FIELD_CHECK_IN_PIC_FID @"452"
#define FIELD_CHECK_OUT_PIC_FID @"453"

#define FIELD_CHECK_IN_PROJECT_FID @"446"
#define FIELD_CHECK_IN_WORKER_FID @"447"
#define FIELD_CHECK_IN_START_TIME_FID @"450"
#define FIELD_CHECK_IN_END_TIME_FID @"449"
#define FIELD_CHECK_IN_PIC_START_FID @"455"
#define FIELD_CHECK_IN_PIC_END_FID @"456"
#define FIELD_CHECK_IN_COST_CODE_FID @"454"
#define FIELD_CHECK_OUT_FLAG_FID @"448"
#define FIELD_CHECK_IN_EMPLOYEE_NAME_FID @"129"
#define FIELD_CHECK_IN_HOURWORKED_FID @"451"

#define FIELD_EMPLOYEE_ID_FID @"54"
#define FIELD_PROJECT_ID_FID @"336"

// Notification Key

#define  NOTI_ADD_WORKER @"Add_Worker"

//Other Value

#define IMAGE_WIDTH 200

#define USER_EMAIL @"UserEmail"
#define USER_PASSWORD @"UserPassword"

#endif
