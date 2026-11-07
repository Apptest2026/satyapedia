const U='https://nlxjzdarpnuawzjhwrlj.supabase.co',K='sb_publishable_jOUtfcqlj7iW0paHZztO-A_pV2PsNj5';
module.exports=async(req,res)=>{
 const o='https://'+(req.headers['x-forwarded-host']||req.headers.host);let rows=[];
 try{const r=await fetch(U+'/rest/v1/profiles?verified=eq.true&hidden=eq.false&select=slug,created_at&limit=5000',{headers:{apikey:K}});if(r.ok)rows=await r.json()}catch(x){}
 const u=(l,s,d)=>'<url><loc>'+o+l+'</loc><lastmod>'+d+'</lastmod><xhtml:link rel="alternate" hreflang="en" href="'+o+'/p/'+s+'"/><xhtml:link rel="alternate" hreflang="hi" href="'+o+'/hi/p/'+s+'"/></url>';
 const body=rows.filter(r=>/^[a-z0-9-]+$/.test(r.slug)).map(r=>{const d=String(r.created_at).slice(0,10);return u('/p/'+r.slug,r.slug,d)+u('/hi/p/'+r.slug,r.slug,d)}).join('');
 res.setHeader('Content-Type','application/xml; charset=utf-8');res.setHeader('Cache-Control','s-maxage=3600');
 res.end('<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml"><url><loc>'+o+'/</loc></url><url><loc>'+o+'/privacy</loc></url><url><loc>'+o+'/terms</loc></url><url><loc>'+o+'/verification</loc></url>'+body+'</urlset>');
};
