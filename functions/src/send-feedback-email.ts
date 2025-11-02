import { onRequest } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import * as cors from 'cors';
import * as nodemailer from 'nodemailer';

const corsHandler = cors({ origin: true });

// Define secret for Gmail App Password
const gmailAppPassword = defineSecret('GMAIL_APP_PASSWORD');

// Email transporter configuration
const createTransporter = (appPassword: string) => {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'ugur.gucluoglu@gmail.com',
      pass: appPassword,
    },
  });
};

// Category labels
const getCategoryLabel = (category: string): string => {
  switch (category) {
    case 'istek':
      return 'İstek';
    case 'oneri':
      return 'Öneri';
    case 'sikayet':
      return 'Şikayet';
    default:
      return category;
  }
};

export const sendFeedbackEmail = onRequest(
  {
    cors: true,
    invoker: 'public',
    secrets: [gmailAppPassword],
  },
  (request, response) => {
    return corsHandler(request, response, async () => {
      try {
        // Sadece POST isteklerine izin ver
        if (request.method !== 'POST') {
          response.status(405).json({ error: 'Method not allowed' });
          return;
        }

        const body = request.body;
        const { name, surname, email, phone, message, category } = body;

        // Validasyon
        if (!message || message.trim().length < 10) {
          response.status(400).json({ error: 'Mesaj zorunludur ve en az 10 karakter olmalıdır' });
          return;
        }

        if (!email && !phone) {
          response.status(400).json({ error: 'E-posta veya telefon numarasından en az biri gereklidir' });
          return;
        }

        if (!category) {
          response.status(400).json({ error: 'Kategori seçimi zorunludur' });
          return;
        }

        // Email transporter oluştur
        const transporter = createTransporter(gmailAppPassword.value());

        const categoryLabel = getCategoryLabel(category);
        const categoryColor = category === 'istek' ? '#3B82F6' : category === 'oneri' ? '#F59E0B' : '#EF4444';

        // Email içeriği
        const mailOptions = {
          from: 'ugur.gucluoglu@gmail.com',
          to: 'ugur.gucluoglu@gmail.com',
          subject: `Tamgacı ${categoryLabel} - ${name || 'İsimsiz'} ${surname || ''}`,
          html: `
            <!DOCTYPE html>
            <html>
            <head>
              <meta charset="UTF-8">
              <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: ${categoryColor}; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
                .content { background-color: #f9f9f9; padding: 20px; border: 1px solid #ddd; border-top: none; }
                .category-badge { display: inline-block; padding: 8px 16px; background-color: ${categoryColor}; color: white; border-radius: 20px; font-weight: bold; margin-bottom: 20px; }
                .field { margin-bottom: 15px; }
                .label { font-weight: bold; color: #0175C2; }
                .value { margin-top: 5px; padding: 10px; background-color: white; border-radius: 3px; border-left: 3px solid ${categoryColor}; }
                .message-box { background-color: white; padding: 15px; border-radius: 3px; border-left: 3px solid ${categoryColor}; margin-top: 10px; }
                .footer { text-align: center; margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="header">
                  <h2>Tamgacı ${categoryLabel}</h2>
                  <p>Yeni bir ${categoryLabel.toLowerCase()} mesajı aldınız</p>
                </div>
                <div class="content">
                  <div class="category-badge">${categoryLabel}</div>
                  
                  ${name || surname ? `
                  <div class="field">
                    <div class="label">Ad Soyad:</div>
                    <div class="value">${name || ''} ${surname || ''}</div>
                  </div>
                  ` : ''}
                  
                  ${email ? `
                  <div class="field">
                    <div class="label">E-posta:</div>
                    <div class="value"><a href="mailto:${email}">${email}</a></div>
                  </div>
                  ` : ''}
                  
                  ${phone ? `
                  <div class="field">
                    <div class="label">Telefon:</div>
                    <div class="value"><a href="tel:${phone}">${phone}</a></div>
                  </div>
                  ` : ''}
                  
                  <div class="field">
                    <div class="label">Mesaj:</div>
                    <div class="message-box">${message.replace(/\n/g, '<br>')}</div>
                  </div>
                </div>
                <div class="footer">
                  <p>Bu mesaj Tamgacı web sitesindeki "İstek, Öneri, Şikayet" formundan gönderilmiştir.</p>
                  <p>Gönderim Zamanı: ${new Date().toLocaleString('tr-TR', { timeZone: 'Europe/Istanbul' })}</p>
                </div>
              </div>
            </body>
            </html>
          `,
          text: `
Tamgacı ${categoryLabel}

${name || surname ? `Ad Soyad: ${name || ''} ${surname || ''}\n` : ''}
${email ? `E-posta: ${email}\n` : ''}
${phone ? `Telefon: ${phone}\n` : ''}

Kategori: ${categoryLabel}

Mesaj:
${message}

---
Bu mesaj Tamgacı web sitesindeki "İstek, Öneri, Şikayet" formundan gönderilmiştir.
Gönderim Zamanı: ${new Date().toLocaleString('tr-TR', { timeZone: 'Europe/Istanbul' })}
          `,
        };

        // Email gönder
        await transporter.sendMail(mailOptions);

        console.log('Feedback email sent successfully');
        response.status(200).json({ 
          success: true, 
          message: 'E-posta başarıyla gönderildi' 
        });

      } catch (error) {
        console.error('Send feedback email error:', error);
        response.status(500).json({ 
          error: 'E-posta gönderilirken bir hata oluştu',
          message: error instanceof Error ? error.message : 'Unknown error'
        });
      }
    });
  }
);

