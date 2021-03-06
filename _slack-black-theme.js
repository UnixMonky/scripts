// First make sure the wrapper app is loaded
document.addEventListener("DOMContentLoaded", function() {

   // Then get its webviews
   let webviews = document.querySelectorAll(".TeamView webview");

   // Fetch our CSS in parallel ahead of time
   // const cssPath = 'https://cdn.rawgit.com/widget-/slack-black-theme/master/custom.css';
   const cssPath = 'https://raw.githubusercontent.com/Nockiro/slack-black-theme/3ea2efdfb96ccc91549837ab237d57104181bbf8/custom.css'
   let cssPromise = fetch(cssPath).then(response => response.text());

   let customCustomCSS = `
   :root {
      /* Modify these to change your theme colors: */
      // Default
      // --primary: #09F;
      // --text: #CCC;
      // --background: #080808;
      // --background-elevated: #222;
      // One Dark
      --primary: #61AFEF;
      --text: #ABB2BF;
      --background: #282C34;
      --background-elevated: #3B4048;
      // Low Contrast
      // --primary: #CCC;
      // --text: #999;
      // --background: #222;
      // --background-elevated: #444;
      // Navy
      // --primary: #FFF;
      // --text: #CCC;
      // --background: #225;
      // --background-elevated: #114;
      // Hot Dog Stand
      // --primary: #000;
      // --text: #FFF;
      // --background: #F00;
      // --background-elevated: #FF0;
   }
   `

   // Insert a style tag into the wrapper view
   cssPromise.then(css => {
      let s = document.createElement('style');
      s.type = 'text/css';
      s.innerHTML = css + customCustomCSS;
      document.head.appendChild(s);
   });

   // Wait for each webview to load
   webviews.forEach(webview => {
      webview.addEventListener('ipc-message', message => {
         if (message.channel == 'didFinishLoading')
            // Finally add the CSS into the webview
            cssPromise.then(css => {
               let script = `
                     let s = document.createElement('style');
                     s.type = 'text/css';
                     s.id = 'slack-custom-css';
                     s.innerHTML = \`${css + customCustomCSS}\`;
                     document.head.appendChild(s);
                     `
               webview.executeJavaScript(script);
            })
      });
   });
});
