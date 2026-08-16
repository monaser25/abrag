-- نقل الشقة: ربط نصّي الإقامة لما ضيف يتنقل من شقة لشقة في نص مدته.
--
-- ⚠️ من غير FOREIGN KEY عن قصد.
--
-- المزامنة بترفع صف صف (upsert لكل حجز لوحده)، ومش بتضمن ترتيب. لما
-- transferBooking بيتعمل، الحجز القديم بياخد transferred_to_booking_id بتاع
-- حجز لسه متولد محليًا ومترفعش. لو حطينا FK، رفع الحجز القديم بيترفض بـ 409
-- والمزامنة بتقف عند نفس الصف كل مرة وتفضل واقفة للأبد.
--
-- حصل ده فعلاً في الإنتاج (١٥–١٦ أغسطس ٢٠٢٦): المزامنة وقفت يوم وربع لحد ما
-- القيدين اتشالوا. الربط بيتضمن في التطبيق — transferBooking بيكتب الاتنين
-- في transaction محلية واحدة.

alter table summer_bookings
  add column if not exists transferred_from_booking_id uuid,
  add column if not exists transferred_to_booking_id uuid;

-- لو انت بتطبّق ده على قاعدة كان اتحط فيها الـ FK قبل كده:
alter table summer_bookings
  drop constraint if exists summer_bookings_transferred_from_booking_id_fkey,
  drop constraint if exists summer_bookings_transferred_to_booking_id_fkey;

comment on column summer_bookings.transferred_from_booking_id is
  'نقل الشقة: الحجز اللي اتنقل منه الضيف. من غير FK عن قصد — المزامنة بترفع صف صف ومش بتضمن الترتيب.';
comment on column summer_bookings.transferred_to_booking_id is
  'نقل الشقة: الحجز اللي اتنقل ليه الضيف. من غير FK عن قصد — المزامنة بترفع صف صف ومش بتضمن الترتيب.';

create index if not exists idx_summer_bookings_transferred_to
  on summer_bookings(transferred_to_booking_id)
  where transferred_to_booking_id is not null;
