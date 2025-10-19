const appFolder = '/storage/emulated/0/حلقات مسجد جابرة';
const local_node = "http://10.0.2.2:9632";
const server_node = "https://jaberahapp-server.onrender.com";

const local_asp = "http://10.0.2.2:5291/api";
const server_asp = "https://jaberah.runasp.net/api";
const IP = "http://192.168.1.20:9632";

const baseUrl = server_asp;

const loginURL = "auth/login";

const groupsURL = "groups";
const groupsForGeneralUseURL = "$groupsURL/for-general-use";

const groupsWithNoTeachers = "$groupsURL/has-no-teacher-data";

const teachersURL = "teachers";
const teachersForGeneralUseURL = "$teachersURL/for-general-use";

const studentsURL = "students";

const groupsWithNoTeachersAndTeacherGroups =
    "groups/has-no-teacher-and-has-teacher";

const teachersSalariesURL = "teachers-salaries";

const teachersAttendancesURL = "teachers-attendances";
const teachersAttendancesForReportByDayURL =
    "teachers-attendances/for-day-report";
const teachersAttendancesForReportByMonthURL =
    "teachers-attendances/for-month-report";

const monthlyReportURL = "reports/monthly-report";
const semesterReportURL = "reports/semester-report";

const bestStudentReportURL = "reports/best-students-report";
const bestStudentForGroupReportURL = "reports/best-students-for-group-report";

const followStudentsURL = "follow-students";
const followStudentsForGroup = "$followStudentsURL/groups";

const monthlyExamsURL = "exams/monthly-exam";
const midFinalExamURL = "exams/mid-final-exam";
const partialExamsURL = "exams/partial-exam";

const notificationsURL = "notifications";
const sendNotificationURL = "$notificationsURL/send";

const refreshFCMTokenURL = "auth/update-fcm-token";
