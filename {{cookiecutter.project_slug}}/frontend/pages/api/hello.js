// Next.js API route support: https://nextjs.org/docs/api-routes/introduction

export default function handler(req, res) {
  res.status(200).json({ name: 'John Doe' });
}

const server = 'http://127.0.0.1:8000';
// const camelToSnakeCase = (str) =>
//   str.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`);

export const fetchTasks = async (setData) => {
  const res = await fetch(`https://{{cookiecutter.project_slug}}-api.local/`, {
    method: 'get',
    // headers: new Headers({
    // Authorization: 'Bearer ' + user.accessToken,
    // withCredentials: true,
    // }),
  });
  const data = await res.json();
  setData(data);
};
