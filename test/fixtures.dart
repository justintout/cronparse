const regexTests = [
  ['asdf', false],
  ['***** ****** ******** **** ***', false],
  ['', false],
  ['     ', false],
  ['*****', false],
  ['***?*', false],
  ['a * 1 2 ? * *', false],
  ['00 *3/2 ) 3', false],
  ["* * * * &", false],
  ['0 0 12 * * *', false],
  ['0 0 12 * *', true],
  ['0 15 10 ? * *', false],
  ['0 15 10 * * ?', false],
  ['15 10 * * *', true],
  ['* 14 * * *', true],
  ['0/5 14 * * *', false],
  ['*/5 14 * * *', true],
  ['0/5 14,18 * * *', false],
  ['*/5 8,15 * * *', true],
  ['0-5 14 * * 3', true],
  ['10,44 14 * 3 WED', true],
  ['15 10 * * MON-FRI', true],
  ['0 15 10 15 * ?', false],
  ['0 15 10 L * ?', false],
  ['0 15 10 ? * 6L', false],
  ['0 15 10 ? * 6L 2002-2005', false],
  ['0 15 10 ? * 6#3', false],
  ['0 0 12 1/5 * ?', false],
  ['0 11 11 11 11 ?', false],
  ['* * * * *', true],
  // tests for minute, validating `_minuteValid`
  ['- * * * *', false],
  ['a * * * *', false],
  ['420 * * * *', false],
  ['-15 * * * *', false],
  ['0 * * * *', true],
  ['59 * * * *', true],
  ['6-9 * * * *', true],
  ['0-4,8-12,58 * * * *', true],
  ['4-8/2 * * * *', true],
  ['*/15 * * * *', true],
  ['1,10-15/15 * * * *', false],
  // tests for hour, validating `_hourValid`
  ['* - * * *', false],
  ['* a * * *', false],
  ['* 420 * * *', false],
  ['* -15 * * *', false],
  ['* 0 * * *', true],
  ['* 23 * * *', true],
  ['* 6-9 * * *', true],
  ['* 0-4,8-12,22 * * *', true],
  ['* 12/2 * * *', false],
  ['* 4-8/2 * * *', true],
  ['* */3 * * *', true],
  ['* 1,10-12/3 * * *', false],
  // tests for day of month, validating `_dayOfMonthValid`
  ['* * - * *', false],
  ['* * a * *', false],
  ['* * 420 * *', false],
  ['* * -15 * *', false],
  ['* * 0 * *', false],
  ['* * 1 * *', true],
  ['* * 31 * *', true],
  ['* * 6-9 * *', true],
  ['* * 0-4,8-12,22 * *', false],
  ['* * 1-4,8-12,22 * *', true],
  ['* * 12<2> * *', false],
  ['* * 12/2 * *', false],
  ['* * 12-28/2 * *', true],
  ['* * 4-8,30/2 * *', false],
  ['* * */3 * *', true],
  // tests for month, validating `_monthValid`
  ['* * * - *', false],
  ['* * * a *', false],
  ['* * * 420 *', false],
  ['* * * -15 *', false],
  ['* * * 0 *', false],
  ['* * * 1 *', true],
  ['* * * 12 *', true],
  ['* * * 6-9 *', true],
  ['* * * 0-4,8-12 *', false],
  ['* * * 1-4,8-12 *', true],
  ['* * * 2<2> *', false],
  ['* * * 1-5/2 *', true],
  ['* * * 4-8<2> *', false],
  ['* * * */3 *', true],
  ['* * * JAN *', true],
  ['* * * feb *', true],
  ['* * * MaR *', true],
  ['* * * aPr *', true],
  ['* * * MaY *', true],
  ['* * * JUN *', true],
  ['* * * Jul *', true],
  ['* * * Aug *', true],
  ['* * * seP *', true],
  ['* * * OTC *', false],
  ['* * * OCT *', true],
  ['* * * NOV *', true],
  ['* * * deC *', true],
  ['* * * JUUL *', false],
  ['* * * febb *', false],
  ['* * * AAAAAA *', false],
  ['* * * JUS *', false],
  ['* * * tin *', false],
  // tests for day of month, validating `_dayOfMonthValid`
  ['* * * * -', false],
  ['* * * * a', false],
  ['* * * * 420', false],
  ['* * * * -15', false],
  ['* * * * 0', true],
  ['* * * * 7', true],
  ['* * * * 6-9', false],
  ['* * * * 0-2,5-7', true],
  ['* * * * 1,2,3', true],
  ['* * * * 2<2>', false],
  ['* * * * 2-6<2>', false],
  ['* * * * */3', true],
  ['* * * * 3-7', true],
  ['* * * * 1-3/2', true],
  ['* * * * 1-3,5/2', false],
  ['* * * * 5/2', false],
  ['* * * * mon', true],
  ['* * * * TUES', false],
  ['* * * * TUE', true],
  ['* * * * wEd', true],
  ['* * * * thU', true],
  ['* * * * FrI', true],
  ['* * * * sAt', true],
  ['* * * * sun', true],
  ['* * * * Jull', false],
  ['* * * * AAAAAA', false],
  ['* * * * JUS', false],
  ['* * * * tin', false],
  // tests for nicknames, validating `_nicknameValid`
  ['@reboot', false],
  ['@yearly', true],
  ['@annually', true],
  ['@monthly', true],
  ['@weekly', true],
  ['@daily', true],
  ['@hourly', true],
  ['@midnight', true],
  ['@', false],
  ['@asdf', false],
  ['@ ', false],
];
