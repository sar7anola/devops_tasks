#!/bin/bash

 "أهم أوامر NGINX ووظائفها:"
 "============================================"
" إدارة الخدمة:"
 "sudo systemctl start nginx     # بدء خدمة NGINX"
 "sudo systemctl stop nginx      # إيقاف خدمة NGINX"
 "sudo systemctl restart nginx   # إعادة تشغيل الخدمة"
 "sudo systemctl reload nginx    # إعادة تحميل الإعدادات بدون توقف"
 "sudo systemctl status nginx    # عرض حالة الخدمة الحالية"

 " اختبار الإعدادات:"
 "sudo nginx -t                  # اختبار صلاحية إعدادات NGINX"
 "sudo nginx -v                  # عرض إصدار NGINX"
 "sudo nginx -V                  # عرض الإصدار + خيارات الـ compile"

 " أوامر مباشرة من nginx:"
 "sudo nginx                     # تشغيل السيرفر"
 "sudo nginx -s stop             # إيقاف السيرفر فورًا"
 "sudo nginx -s quit             # إيقاف السيرفر بشكل آمن"
 "sudo nginx -s reload           # إعادة تحميل الإعدادات"
 "sudo nginx -s reopen           # إعادة فتح ملفات الـ log"

 " ملفات مهمة:"
 "/etc/nginx/nginx.conf          # ملف الإعداد الرئيسي"
 "/etc/nginx/sites-available/    # ملفات المواقع المتوفرة"
 "/etc/nginx/sites-enabled/      # ملفات المواقع المفعّلة"
 "/var/log/nginx/access.log      # سجل الطلبات الواردة"
 "/var/log/nginx/error.log       # سجل الأخطاء"

" مراقبة السجلات:"
 "tail -f /var/log/nginx/access.log   # متابعة سجل الوصول"
 "tail -f /var/log/nginx/error.log    # متابعة سجل الأخطاء"
 