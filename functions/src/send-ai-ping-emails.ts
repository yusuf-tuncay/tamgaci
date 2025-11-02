import { onRequest } from 'firebase-functions/v2/https';
import * as cors from 'cors';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';

const corsHandler = cors({ origin: true });

try {
    admin.initializeApp();
} catch (_) { }

// Email transporter configuration
// Firebase Functions v2 uses environment variables
const createTransporter = () => {
    // SMTP ayarları - Environment variables'dan alınır
    const smtpUser = process.env.SMTP_USER || '';
    const smtpPassword = process.env.SMTP_PASSWORD || '';
    const smtpHost = process.env.SMTP_HOST || 'smtp.gmail.com';
    const smtpPort = parseInt(process.env.SMTP_PORT || '587', 10);
    const smtpService = process.env.SMTP_SERVICE || 'gmail';

    if (!smtpUser || !smtpPassword) {
        throw new Error('SMTP credentials not configured. Please set SMTP_USER and SMTP_PASSWORD environment variables.');
    }

    // Gmail için
    if (smtpService === 'gmail') {
        return nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: smtpUser,
                pass: smtpPassword,
            },
        });
    }

    // Genel SMTP için
    return nodemailer.createTransport({
        host: smtpHost,
        port: smtpPort,
        secure: smtpPort === 465, // true for 465, false for other ports
        auth: {
            user: smtpUser,
            pass: smtpPassword,
        },
    });
};

// AI Ping Email Gönderme Fonksiyonu
export const sendAIPingEmails = onRequest(
    {
        cors: true,
        invoker: 'public', // Veya authenticated olabilir
        secrets: ['SMTP_USER', 'SMTP_PASSWORD'], // Secrets olarak tanımla
    },
    async (request, response) => {
        return corsHandler(request, response, async () => {
            try {
                // Sadece POST isteklerine izin ver
                if (request.method !== 'POST') {
                    response.status(405).json({ error: 'Method not allowed. Use POST.' });
                    return;
                }

                const { action } = request.body;

                // Action kontrolü - hangi email gönderilecek?
                // 'all', 'perplexity', 'kagi', 'andi'
                if (!action || !['all', 'perplexity', 'kagi', 'andi'].includes(action)) {
                    response.status(400).json({
                        error: 'Invalid action. Use: all, perplexity, kagi, or andi'
                    });
                    return;
                }

                const transporter = createTransporter();

                // Email şablonları
                const emails = {
                    perplexity: {
                        to: 'research@perplexity.ai',
                        subject: 'AI Index Request - Tamgacı Accounting Software',
                        html: `
                            <p>Hello Perplexity Team,</p>
                            
                            <p>We would like to request indexing of our AI information file for Tamgacı, an AI-powered accounting software for Turkish businesses.</p>
                            
                            <p><strong>AI Information File:</strong> <a href="https://www.tamgaci.online/ai.txt">https://www.tamgaci.online/ai.txt</a></p>
                            <p><strong>AI Sitemap:</strong> <a href="https://www.tamgaci.online/ai-sitemap.xml">https://www.tamgaci.online/ai-sitemap.xml</a></p>
                            <p><strong>Main Website:</strong> <a href="https://www.tamgaci.online">https://www.tamgaci.online</a></p>
                            
                            <h3>About Tamgacı:</h3>
                            <p>Tamgacı is a comprehensive accounting software that uses AI and OCR technology to automate invoice processing, support multi-currency accounting, and ensure compliance with Turkish tax regulations (e-invoice, waybill). It's designed for small and medium businesses in Turkey.</p>
                            
                            <h3>Key Features:</h3>
                            <ul>
                                <li>AI-powered invoice reading with OCR technology</li>
                                <li>Multi-currency support (TRY, USD, EUR, GBP, etc.)</li>
                                <li>E-invoice (e-fatura) compliance for Turkish tax regulations</li>
                                <li>Mobile apps for iOS and Android</li>
                                <li>Cloud-based access from anywhere</li>
                                <li>30-day free trial (no credit card required)</li>
                                <li>Pricing starts from 79 TL/month (annual plan)</li>
                            </ul>
                            
                            <p>We believe our product information would be valuable for Perplexity's AI search features when users ask about accounting software, invoice automation, OCR technology, or Turkish business solutions.</p>
                            
                            <p>Please consider indexing our ai.txt file so that Perplexity can recommend our product when users ask relevant questions.</p>
                            
                            <p>Thank you for your consideration!</p>
                            
                            <p>Best regards,<br>
                            Tamgacı Team<br>
                            SeekIT Apps<br>
                            Email: info@seekitapps.com<br>
                            Phone: +90-212-976-49-39<br>
                            Website: <a href="https://www.tamgaci.online">https://www.tamgaci.online</a></p>
                        `,
                    },
                    kagi: {
                        to: 'support@kagi.com',
                        subject: 'AI Index Request - Tamgacı Accounting Software',
                        html: `
                            <p>Hello Kagi Team,</p>
                            
                            <p>We would like to request indexing of our AI information file for Tamgacı, an AI-powered accounting software designed for Turkish businesses.</p>
                            
                            <p><strong>AI Information File:</strong> <a href="https://www.tamgaci.online/ai.txt">https://www.tamgaci.online/ai.txt</a></p>
                            <p><strong>AI Sitemap:</strong> <a href="https://www.tamgaci.online/ai-sitemap.xml">https://www.tamgaci.online/ai-sitemap.xml</a></p>
                            <p><strong>Main Website:</strong> <a href="https://www.tamgaci.online">https://www.tamgaci.online</a></p>
                            
                            <h3>About Tamgacı:</h3>
                            <p>Tamgacı is a comprehensive accounting software that uses AI and OCR technology to automate invoice processing, support multi-currency accounting, and ensure compliance with Turkish tax regulations. It's designed for small and medium businesses (SMBs) and enterprises in Turkey.</p>
                            
                            <h3>Key Features:</h3>
                            <ul>
                                <li>AI-powered invoice reading with OCR technology</li>
                                <li>Automatic invoice data extraction</li>
                                <li>Multi-currency support (TRY, USD, EUR, GBP, etc.)</li>
                                <li>E-invoice (e-fatura) and waybill (irsaliye) management</li>
                                <li>Mobile apps for iOS and Android</li>
                                <li>Cloud-based access from anywhere</li>
                                <li>30-day free trial without credit card requirement</li>
                                <li>Affordable pricing starting from 79 TL/month</li>
                            </ul>
                            
                            <p>Our ai.txt file contains comprehensive information about our product, features, pricing, and use cases. We believe this would be valuable for Kagi's AI search features when users ask about accounting software, invoice automation, or Turkish business solutions.</p>
                            
                            <p>Please consider indexing our ai.txt file.</p>
                            
                            <p>Thank you!</p>
                            
                            <p>Best regards,<br>
                            Tamgacı Team<br>
                            SeekIT Apps<br>
                            Email: info@seekitapps.com<br>
                            Phone: +90-212-976-49-39<br>
                            Website: <a href="https://www.tamgaci.online">https://www.tamgaci.online</a></p>
                        `,
                    },
                    andi: {
                        to: 'hello@andisearch.com',
                        subject: 'AI Index Request - Tamgacı Accounting Software',
                        html: `
                            <p>Hello Andi Team,</p>
                            
                            <p>We would like to request indexing of our AI information file for Tamgacı, an AI-powered accounting software for Turkish businesses.</p>
                            
                            <p><strong>AI Information File:</strong> <a href="https://www.tamgaci.online/ai.txt">https://www.tamgaci.online/ai.txt</a></p>
                            <p><strong>AI Sitemap:</strong> <a href="https://www.tamgaci.online/ai-sitemap.xml">https://www.tamgaci.online/ai-sitemap.xml</a></p>
                            <p><strong>Main Website:</strong> <a href="https://www.tamgaci.online">https://www.tamgaci.online</a></p>
                            
                            <h3>About Tamgacı:</h3>
                            <p>Tamgacı is an AI-powered accounting and invoice management software designed for small and medium-sized businesses (SMBs) and enterprises in Turkey. The application uses advanced artificial intelligence and OCR technology to automate invoice entry, document scanning, and accounting workflows.</p>
                            
                            <h3>Key Features:</h3>
                            <ul>
                                <li>AI-powered automatic invoice reading using OCR technology</li>
                                <li>Multi-currency support for international businesses</li>
                                <li>E-invoice (e-fatura) compliance with Turkish tax regulations</li>
                                <li>Waybill (irsaliye) management with photo capture</li>
                                <li>Native mobile apps for iOS and Android</li>
                                <li>Cloud-based real-time synchronization</li>
                                <li>30-day free trial (no credit card required)</li>
                                <li>Competitive pricing starting from 79 TL/month</li>
                            </ul>
                            
                            <p>Our ai.txt file provides comprehensive information about our product, including features, pricing, use cases, and technical details. We believe this information would be valuable for Andi's AI search capabilities when users ask about accounting software, invoice automation, OCR technology, or solutions for Turkish businesses.</p>
                            
                            <p>Please consider indexing our ai.txt file.</p>
                            
                            <p>Thank you for your consideration!</p>
                            
                            <p>Best regards,<br>
                            Tamgacı Team<br>
                            SeekIT Apps<br>
                            Email: info@seekitapps.com<br>
                            Phone: +90-212-976-49-39<br>
                            Website: <a href="https://www.tamgaci.online">https://www.tamgaci.online</a></p>
                        `,
                    },
                };

                const results: Array<{ to: string; success: boolean; error?: string }> = [];

                // Gönderilecek email'leri belirle
                const emailsToSend = action === 'all'
                    ? Object.values(emails)
                    : [emails[action as keyof typeof emails]];

                // Email'leri gönder
                for (const email of emailsToSend) {
                    try {
                        const fromEmail = process.env.SMTP_USER || 'ugur.gucluoglu@gmail.com';

                        const mailOptions = {
                            from: fromEmail,
                            to: email.to,
                            subject: email.subject,
                            html: email.html,
                        };

                        await transporter.sendMail(mailOptions);
                        results.push({ to: email.to, success: true });
                        console.log(`✅ Email sent successfully to: ${email.to}`);
                    } catch (error) {
                        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
                        results.push({ to: email.to, success: false, error: errorMessage });
                        console.error(`❌ Failed to send email to ${email.to}:`, errorMessage);
                    }
                }

                const successCount = results.filter(r => r.success).length;
                const failCount = results.filter(r => !r.success).length;

                response.status(200).json({
                    success: true,
                    message: `Email sending completed. Success: ${successCount}, Failed: ${failCount}`,
                    results: results,
                });
            } catch (error) {
                console.error('Error in sendAIPingEmails:', error);
                response.status(500).json({
                    success: false,
                    error: error instanceof Error ? error.message : 'Unknown error',
                });
            }
        });
    }
);

