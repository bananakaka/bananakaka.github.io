hexo generate
cp -R public/* .deploy/tinyivc.github.io
cd .deploy/tinyivc.github.io
git add .
git commit -m "update"
git push origin master

