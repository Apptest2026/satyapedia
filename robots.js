module.exports=(req,res)=>{const o='https://'+(req.headers['x-forwarded-host']||req.headers.host);
 res.setHeader('Content-Type','text/plain');res.end('User-agent: *\nAllow: /\nSitemap: '+o+'/sitemap.xml\n')};
