const U='https://nlxjzdarpnuawzjhwrlj.supabase.co',K='sb_publishable_jOUtfcqlj7iW0paHZztO-A_pV2PsNj5';
const q=async p=>{try{const r=await fetch(U+'/rest/v1/'+p,{headers:{apikey:K}});return r.ok?await r.json():[]}catch(x){return[]}};
const e=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const TK={en:{common:'Common person',biz:'Business (GST)',gov:'Government',opp:'Opposition',celeb:'Celebrity',premium:'Celebrity Premium'},hi:{common:'आम नागरिक',biz:'बिज़नेस (GST)',gov:'सरकार',opp:'विपक्ष',celeb:'सेलिब्रिटी',premium:'सेलिब्रिटी प्रीमियम'}};
const CT={en:{Politician:'Politician',Celebrity:'Celebrity',Business:'Business / Shop',Professional:'Doctor / Lawyer / Teacher',Artist:'Artist / Creator',Journalist:'Journalist',Farmer:'Farmer',Student:'Student',Other:'Other'},hi:{Politician:'राजनेता',Celebrity:'सेलिब्रिटी',Business:'बिज़नेस / दुकान',Professional:'डॉक्टर / वकील / शिक्षक',Artist:'कलाकार / क्रिएटर',Journalist:'पत्रकार',Farmer:'किसान',Student:'विद्यार्थी',Other:'अन्य'}};
const T={en:{name:'Name',founder:'Founder / Full name',est:'Established / Born',gst:'GST',address:'Address',product:'Product / Work',vals:'Core values',bio:'About',headline:'Intro',city:'City',category:'Category',personal:'Personal',business:'Business',log:'Edit history',total:'Total edits',none:'No edits yet',unv:'KYC not yet verified',vr:'KYC verified',cta:'Create your free verified page',home:'Home',lock:'Locked after verification',type:'Type',tick:'Tick',nf:'Profile not found'},
hi:{name:'नाम',founder:'संस्थापक / पूरा नाम',est:'स्थापना / जन्म',gst:'GST',address:'पता',product:'उत्पाद / काम',vals:'मुख्य मूल्य',bio:'परिचय',headline:'संक्षिप्त परिचय',city:'शहर',category:'श्रेणी',personal:'व्यक्तिगत',business:'बिज़नेस',log:'बदलाव का इतिहास',total:'कुल बदलाव',none:'अभी कोई बदलाव नहीं',unv:'KYC अभी सत्यापित नहीं',vr:'KYC सत्यापित',cta:'अपना मुफ़्त सत्यापित पेज बनाएँ',home:'मुख्य पृष्ठ',lock:'सत्यापन के बाद लॉक',type:'प्रकार',tick:'टिक',nf:'प्रोफ़ाइल नहीं मिली'}};
const TC={common:'#202122',biz:'#14866d',gov:'#1d9bf0',opp:'#1d9bf0',celeb:'#b8860b',premium:'#b8860b'};
const CSS='body{margin:0;background:#f6f6f6;color:#202122;font:15px/1.65 "Segoe UI",Arial,"Noto Sans Devanagari",sans-serif}a{color:#3366cc;text-decoration:none}a:hover{text-decoration:underline}header{display:flex;justify-content:space-between;background:#fff;border-bottom:1px solid #a2a9b1;padding:8px 16px;flex-wrap:wrap;gap:8px}.logo{font:700 20px Georgia,serif;color:#202122}main{max-width:980px;margin:0 auto;background:#fff;border:1px solid #a2a9b1;border-top:0;padding:16px 24px 24px}h1,h2{font-family:Georgia,serif;font-weight:400;border-bottom:1px solid #a2a9b1;margin:14px 0 8px}h1{font-size:28px}h2{font-size:20px}.info{float:right;width:290px;margin:0 0 12px 16px;border:1px solid #a2a9b1;background:#f8f9fa;font-size:13px}.ti{background:#eaecf0;text-align:center;font-weight:700;padding:6px}.info table{width:100%;border-collapse:collapse}.info th,.info td{padding:4px 8px;text-align:left;vertical-align:top;border-top:1px solid #eaecf0}.info th{width:40%}.lk{background:#fef6e7}.tick{display:inline-block;width:20px;height:20px;border-radius:50%;color:#fff;font-size:12px;text-align:center;line-height:20px;margin-left:6px;vertical-align:middle}.box{border:1px solid #a2a9b1;background:#f8f9fa;padding:8px 12px;margin:10px 0;font-size:13px}.foot{border-top:1px solid #a2a9b1;margin-top:22px;padding-top:8px;font-size:12px;color:#54595d;clear:both}table.t{border-collapse:collapse;width:100%;font-size:12px}.t th,.t td{border:1px solid #a2a9b1;padding:3px 6px;text-align:left}.t th{background:#eaecf0}@media(max-width:700px){.info{float:none;width:100%;margin:0 0 12px}main{padding:12px}}';
module.exports=async(req,res)=>{
 const slug=String(req.query.slug||''),lang=req.query.lang==='hi'?'hi':'en',t=T[lang];
 const o='https://'+(req.headers['x-forwarded-host']||req.headers.host);
 const out=(c,h)=>{res.statusCode=c;res.setHeader('Content-Type','text/html; charset=utf-8');res.setHeader('Cache-Control',c===200?'s-maxage=300, stale-while-revalidate=3600':'no-store');res.end(h)};
 const nf='<!DOCTYPE html><html lang="'+lang+'"><head><meta charset="utf-8"><meta name="robots" content="noindex"><title>404</title></head><body style="font-family:sans-serif;padding:30px"><h1>'+t.nf+'</h1><a href="/">'+t.home+'</a></body></html>';
 if(!/^[a-z0-9-]{1,80}$/.test(slug))return out(404,nf);
 const[p]=await q('profiles?slug=eq.'+slug+'&select=*');if(!p)return out(404,nf);
 const ed=await q('edits?profile_id=eq.'+p.id+'&order=at.desc&limit=30&select=*');
 const biz=p.kind==='business',cat=p.category?CT[lang][p.category]||p.category:'';
 const auto=lang==='hi'?p.name+(p.city?', '+p.city+' (भारत) से जुड़े हैं':' भारत से जुड़े हैं')+(cat?' और "'+cat+'" श्रेणी में सूचीबद्ध हैं':'')+'।'+(biz&&p.founder?' संस्थापक: '+p.founder+(p.est?' ('+p.est+')':'')+'।':'')+(p.product?' काम/उत्पाद: '+p.product+'।':''):
  p.name+(p.city?' is based in '+p.city+', India':' is from India')+(cat?' and is listed as '+cat:'')+'.'+(biz&&p.founder?' Founded by '+p.founder+(p.est?' ('+p.est+')':'')+'.':'')+(p.product?' Offers: '+p.product+'.':'');
 const about=p.bio||auto,desc=(p.headline||about).replace(/\s+/g,' ').slice(0,155);
 const url=o+(lang==='hi'?'/hi':'')+'/p/'+slug,title=p.name+(cat?' – '+cat:'')+(p.city?', '+p.city:'')+' | SatyaPedia ✔';
 const ld={'@context':'https://schema.org','@type':biz?'Organization':'Person',name:p.name,url,description:desc};
 if(p.city)ld.address={'@type':'PostalAddress',addressLocality:p.city,addressCountry:'IN'};
 if(biz){if(p.founder)ld.founder={'@type':'Person',name:p.founder};if(/^\d{4}(-\d\d-\d\d)?$/.test(p.est||''))ld.foundingDate=p.est;if(p.gst)ld.taxID=p.gst}else if(cat)ld.jobTitle=cat;
 const row=(k,x,l)=>x?'<tr'+(l?' class="lk"':'')+'><th>'+t[k]+(l?' 🔒':'')+'</th><td>'+e(x)+'</td></tr>':'';
 const tick=p.verified?'<span class="tick" style="background:'+TC[p.tick]+'" title="'+e(TK[lang][p.tick])+'">✓</span>':'';
 const alt=lang==='hi'?'/p/'+slug:'/hi/p/'+slug;
 out(200,'<!DOCTYPE html><html lang="'+lang+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+e(title)+'</title>'+
 '<meta name="description" content="'+e(desc)+'"><meta name="robots" content="'+(p.verified?'index,follow,max-image-preview:large':'noindex,follow')+'"><link rel="canonical" href="'+e(url)+'">'+
 '<link rel="alternate" hreflang="en" href="'+e(o+'/p/'+slug)+'"><link rel="alternate" hreflang="hi" href="'+e(o+'/hi/p/'+slug)+'"><link rel="alternate" hreflang="x-default" href="'+e(o+'/p/'+slug)+'">'+
 '<meta property="og:type" content="profile"><meta property="og:site_name" content="SatyaPedia"><meta property="og:title" content="'+e(title)+'"><meta property="og:description" content="'+e(desc)+'"><meta property="og:url" content="'+e(url)+'"><meta name="twitter:card" content="summary">'+
 '<script type="application/ld+json">'+JSON.stringify(ld).replace(/</g,'\\u003c')+'</script><style>'+CSS+'</style></head><body>'+
 '<header><a class="logo" href="/">SatyaPedia ✔</a><span><a href="'+alt+'">'+(lang==='hi'?'English':'हिंदी')+'</a></span></header><main><article>'+
 '<h1>'+e(p.name)+tick+'</h1>'+(p.headline?'<p><i>'+e(p.headline)+'</i></p>':'')+
 '<div class="info"><div class="ti">'+e(p.name)+'</div><table>'+row('name',p.name,1)+row('founder',p.founder,1)+row('est',p.est,1)+(biz?row('gst',p.gst,1):'')+row('city',p.city)+row('category',cat)+row('address',p.address)+row('product',p.product)+
 '<tr><th>'+t.type+'</th><td>'+t[p.kind]+' · '+e(TK[lang][p.tick])+'</td></tr></table></div>'+
 '<div class="box">'+(p.verified?'✔ '+t.vr:'⏳ '+t.unv)+'</div>'+
 '<h2>'+t.bio+'</h2><p>'+e(about)+'</p>'+(p.vals?'<h2>'+t.vals+'</h2><p>'+e(p.vals)+'</p>':'')+
 '<div class="foot"><b>'+t.log+'</b> — '+t.total+': <b>'+p.edits+'</b><table class="t">'+(ed.length?ed.map(x=>'<tr><td>'+new Date(x.at).toISOString().slice(0,10)+'</td><td>'+e(t[x.field]||x.field)+'</td><td>'+e(x.old_v||'—')+' → '+e(x.new_v||'—')+'</td></tr>').join(''):'<tr><td>'+t.none+'</td></tr>')+'</table><p><a href="/">'+t.cta+'</a></p></div>'+
 '</article></main></body></html>');
};
