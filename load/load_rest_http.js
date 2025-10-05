import http from 'k6/http';
export const options = { vus: 20, duration: '30s' };
export default function () {
  http.get('http://pspd-rest.local/a/hello?name=pspd');
  http.get('http://pspd-rest.local/b/numbers?count=10&delay_ms=5');
}
